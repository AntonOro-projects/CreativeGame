/**
 * Capability that handles player interaction with interactable objects.
 * Shows prompts when near interactable objects and handles input for interaction.
 * Uses an event-based system to broadcast interaction events to other capabilities.
 */
class UInteractionCapability : UBaseCapability
{
    // Replicate this component so RPCs are valid across network
    default bReplicates = true;
    // Interaction sphere for detecting nearby interactables (when this actor can interact)
    UPROPERTY()
    USphereComponent InteractionSphere;

    // Whether to auto-create interaction sphere for detecting nearby objects
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Interaction")
    bool bAutoCreateInteractionSphere = true;

    // Radius for interaction detection
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Interaction")
    float InteractionRadius = 200.0f;
    // Input action for interaction
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input")
    UInputAction InteractAction;

    // Input mapping context for interaction
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input")
    UInputMappingContext InteractionInputContext;

    // Currently registered interactables
    TArray<AActor> NearbyInteractables;

    // Cached references
    UEnhancedInputComponent CachedInputComponent;
    ABaseECSPlayerController CachedPlayerController;
    ABaseECSCharacter CachedCharacter;
    UPlayerHUDCapability CachedHUDCapability;

    // UI/Display settings
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Display")
    bool bShowInteractionPrompts = true;

    // Current interaction target
    AActor CurrentInteractionTarget;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive()
    {
        // Active when attached to a character
        return Cast<ABaseECSCharacter>(GetOwner()) != nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityActivated()
    {
        // Cache references
        CachedCharacter = Cast<ABaseECSCharacter>(GetOwner());
        if (CachedCharacter != nullptr)
        {
            CachedPlayerController = Cast<ABaseECSPlayerController>(CachedCharacter.GetController());
        }

        // Get HUD capability for displaying interaction prompts
        CachedHUDCapability = UPlayerHUDCapability::Get(GetOwner());

        // Create interaction sphere for detecting nearby interactables (if this is a player)
        if (CachedCharacter != nullptr && bAutoCreateInteractionSphere)
        {
            CreateInteractionSphere();
        }

        // Set up input if we have a player controller
        if (CachedPlayerController != nullptr)
        {
            SetupInput();
        }
    }

    void CreateInteractionSphere()
    {
        AActor OwnerActor = GetOwner();
        if (OwnerActor == nullptr)
            return;

        // Create sphere component for detecting nearby interactables
        InteractionSphere = USphereComponent::Create(OwnerActor);
        if (InteractionSphere != nullptr)
        {
            // Set up collision
            InteractionSphere.SetSphereRadius(InteractionRadius);
            InteractionSphere.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
            
            // Bind overlap events
            InteractionSphere.OnComponentBeginOverlap.AddUFunction(this, n"OnInteractionSphereBeginOverlap");
            InteractionSphere.OnComponentEndOverlap.AddUFunction(this, n"OnInteractionSphereEndOverlap");
            
            Log(f"Created interaction sphere for {OwnerActor.GetName()} with radius {InteractionRadius}");
        }
        else
        {
            Log(f"Failed to create interaction sphere for {OwnerActor.GetName()}");
        }
    }

    UFUNCTION()
    void OnInteractionSphereBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, 
        UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
    {
        // Check if the other actor has any interaction capabilities
        UCapabilityManagerComponent OtherCapManager = UCapabilityManagerComponent::Get(OtherActor);
        if (OtherCapManager != nullptr)
        {
            RegisterInteractable(OtherActor);
            Log(f"Registered {OtherActor.GetName()} as interactable with {GetOwner().GetName()}");
        }
    }

    UFUNCTION()
    void OnInteractionSphereEndOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, 
        UPrimitiveComponent OtherComp, int OtherBodyIndex)
    {
        UnregisterInteractable(OtherActor);
        Log(f"Unregistered {OtherActor.GetName()} from {GetOwner().GetName()}");
    
        CachedHUDCapability = UPlayerHUDCapability::Get(GetOwner());

        if (CachedPlayerController != nullptr)
        {
            SetupInput();
        }
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityDeactivated()
    {
        CleanupInput();
        
        // Clean up interaction sphere
        if (InteractionSphere != nullptr)
        {
            InteractionSphere.DestroyComponent();
            InteractionSphere = nullptr;
        }
        
        // Clear all references
        NearbyInteractables.Empty();
        CurrentInteractionTarget = nullptr;
        CachedInputComponent = nullptr;
        CachedPlayerController = nullptr;
        CachedCharacter = nullptr;
        CachedHUDCapability = nullptr;
    
        CachedHUDCapability = nullptr;
    }

    void SetupInput()
    {
        if (CachedPlayerController == nullptr || CachedCharacter == nullptr)
            return;

        // Get input actions from the character
        ANormalPlayerCharacter PlayerCharacter = Cast<ANormalPlayerCharacter>(CachedCharacter);
        if (PlayerCharacter == nullptr)
        {
            Log("Failed to cast character to ANormalPlayerCharacter for interaction input");
            return;
        }

        // Create and set up enhanced input component
        CachedInputComponent = UEnhancedInputComponent::Create(CachedPlayerController);
        CachedPlayerController.PushInputComponent(CachedInputComponent);

        // Add mapping context if provided
        if (PlayerCharacter.InteractionInputContext != nullptr)
        {
            UEnhancedInputLocalPlayerSubsystem EnhancedInputSubsystem = UEnhancedInputLocalPlayerSubsystem::Get(CachedPlayerController);
            if (EnhancedInputSubsystem != nullptr)
            {
                EnhancedInputSubsystem.AddMappingContext(PlayerCharacter.InteractionInputContext, 2, FModifyContextOptions());
            }
        }

        // Bind interact action
        if (PlayerCharacter.InteractAction != nullptr)
        {
            CachedInputComponent.BindAction(PlayerCharacter.InteractAction, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"OnInteractPressed"));
        }
    }

    void CleanupInput()
    {
        if (CachedPlayerController != nullptr && CachedCharacter != nullptr)
        {
            ANormalPlayerCharacter PlayerCharacter = Cast<ANormalPlayerCharacter>(CachedCharacter);
            if (PlayerCharacter != nullptr && PlayerCharacter.InteractionInputContext != nullptr)
            {
                UEnhancedInputLocalPlayerSubsystem EnhancedInputSubsystem = UEnhancedInputLocalPlayerSubsystem::Get(CachedPlayerController);
                if (EnhancedInputSubsystem != nullptr)
                {
                    EnhancedInputSubsystem.RemoveMappingContext(PlayerCharacter.InteractionInputContext, FModifyContextOptions());
                }
            }
        }

        if (CachedInputComponent != nullptr && CachedPlayerController != nullptr)
        {
            CachedPlayerController.PopInputComponent(CachedInputComponent);
            CachedInputComponent = nullptr;
        }
    }

    UFUNCTION()
    void OnInteractPressed(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        if (CurrentInteractionTarget != nullptr)
        {
            TryInteractWith(CurrentInteractionTarget);
        }
    }

    UFUNCTION(BlueprintCallable, Category = "Interaction")
    void RegisterInteractable(AActor Interactable)
    {
        if (Interactable != nullptr && !NearbyInteractables.Contains(Interactable))
        {
            NearbyInteractables.Add(Interactable);
            UpdateCurrentInteractionTarget();
            Log(f"Registered interactable: {Interactable.GetName()}");
        }
    }

    UFUNCTION(BlueprintCallable, Category = "Interaction")
    void UnregisterInteractable(AActor Interactable)
    {
        if (Interactable != nullptr)
        {
            NearbyInteractables.Remove(Interactable);
            if (CurrentInteractionTarget == Interactable)
            {
                CurrentInteractionTarget = nullptr;
                // Hide interaction prompt when target is removed
                HideInteractionPrompt();
            }
            UpdateCurrentInteractionTarget();
            Log(f"Unregistered interactable: {Interactable.GetName()}");
        }
    }

    void UpdateCurrentInteractionTarget()
    {
        CurrentInteractionTarget = nullptr;

        if (NearbyInteractables.Num() == 0)
        {
            return;
        }

        // For now, just use the first available interactable
        // In a more complex system, you might want to choose the closest one
        CurrentInteractionTarget = NearbyInteractables[0];

        if (bShowInteractionPrompts)
        {
            ShowInteractionPrompt();
        }
    }

    void ShowInteractionPrompt()
    {
        if (CurrentInteractionTarget == nullptr)
        {
            HideInteractionPrompt();
            return;
        }

        // Try to get interaction text from a pickup capability
        UActorPickupCapability PickupCap = UActorPickupCapability::Get(CurrentInteractionTarget);
        FString InteractionText;
        
        if (PickupCap != nullptr)
        {
            InteractionText = "Press E to pickup";
        }
        else
        {
            // Use default interaction text for non-pickup items
            InteractionText = "Press F to interact";
        }

        // Try to get HUD capability if we don't have it cached
        if (CachedHUDCapability == nullptr)
        {
            CachedHUDCapability = UPlayerHUDCapability::Get(GetOwner());
        }

        // Display on HUD if available, otherwise log to console
        if (CachedHUDCapability != nullptr)
        {
            CachedHUDCapability.ShowInteractionPrompt(InteractionText);
        }
        else
        {
            Log(f"INTERACTION PROMPT: {InteractionText}");
        }
    }

    void HideInteractionPrompt()
    {
        // Try to get HUD capability if we don't have it cached
        if (CachedHUDCapability == nullptr)
        {
            CachedHUDCapability = UPlayerHUDCapability::Get(GetOwner());
        }
        
        // Hide from HUD if available
        if (CachedHUDCapability != nullptr)
        {
            CachedHUDCapability.HideInteractionPrompt();
        }
        else
        {
            Log("INTERACTION PROMPT HIDDEN");
        }
    }

    void TryInteract()
    {
        if (CurrentInteractionTarget != nullptr)
        {
            bool bSuccess = TryInteractWith(CurrentInteractionTarget);
            if (bSuccess)
            {
                HideInteractionPrompt();
            }
        }
        else
        {
            Log("No interaction available");
        }
    }

    bool TryInteractWith(AActor Target)
    {
        if (Target == nullptr)
            return false;

        Log(f"Broadcasting interaction event for {Target.GetName()}");

    // Always route interaction through the server so resulting actions replicate
    Server_BroadcastInteraction(Target);
        
        // For now, we'll return true if any capability was found on the target
        // The actual success/failure will be determined by the responding capabilities
        UCapabilityManagerComponent TargetCapManager = UCapabilityManagerComponent::Get(Target);
        if (TargetCapManager != nullptr)
        {
            Log(f"Target {Target.GetName()} has capability manager - interaction should be handled");
            return true;
        }

        Log(f"No capability manager found on {Target.GetName()}");
        return false;
    }

    // Server RPC to broadcast the interaction to target capabilities
    UFUNCTION(Server)
    void Server_BroadcastInteraction(AActor Target)
    {
        if (Target == nullptr)
            return;

        BroadcastInteractionEvent(Target, "OnInteractionStarted");
    }

    // Broadcast interaction events to all capabilities on the target actor
    void BroadcastInteractionEvent(AActor Target, FString EventName)
    {
        if (Target == nullptr)
            return;

        UCapabilityManagerComponent TargetCapManager = UCapabilityManagerComponent::Get(Target);
        if (TargetCapManager == nullptr)
            return;

        // Get all capabilities and check if they have interaction event handlers
        TArray<UBaseCapability> AllCapabilities = TargetCapManager.GetAllCapabilities();
        
        for (UBaseCapability Capability : AllCapabilities)
        {
            if (Capability != nullptr)
            {
                // Try to call the interaction event method if it exists
                if (EventName == "OnInteractionStarted")
                {
                    // Check if the capability has an OnInteractionStarted method
                    UActorPickupCapability PickupCap = Cast<UActorPickupCapability>(Capability);
                    if (PickupCap != nullptr)
                    {
                        PickupCap.OnInteractionStarted(GetOwner(), Target);
                    }
                }
            }
        }
    }

    // Called by other capabilities to report interaction results
    UFUNCTION(BlueprintCallable, Category = "Interaction Events")
    void OnInteractionHandled(AActor InteractingActor, AActor TargetActor, bool bSuccess)
    {
        if (bSuccess)
        {
            Log(f"Interaction with {TargetActor.GetName()} was handled successfully");
            
            // Remove from nearby interactables if it was consumed
            UnregisterInteractable(TargetActor);
        }
        else
        {
            Log(f"Interaction with {TargetActor.GetName()} failed");
        }
    }

    UFUNCTION(BlueprintOverride)
    void TickCapability(float DeltaTime)
    {
        // Clean up any invalid interactables
        for (int32 i = NearbyInteractables.Num() - 1; i >= 0; i--)
        {
            if (!IsValid(NearbyInteractables[i]))
            {
                NearbyInteractables.RemoveAt(i);
            }
        }

        // Update interaction target if needed
        if (CurrentInteractionTarget == nullptr && NearbyInteractables.Num() > 0)
        {
            UpdateCurrentInteractionTarget();
        }
    }

    // Utility functions
    UFUNCTION(BlueprintPure, Category = "Interaction")
    bool HasNearbyInteractables() const
    {
        return NearbyInteractables.Num() > 0;
    }

    UFUNCTION(BlueprintPure, Category = "Interaction")
    AActor GetCurrentInteractionTarget() const
    {
        return CurrentInteractionTarget;
    }

    UFUNCTION(BlueprintPure, Category = "Interaction")
    TArray<AActor> GetNearbyInteractables() const
    {
        return NearbyInteractables;
    }
};
