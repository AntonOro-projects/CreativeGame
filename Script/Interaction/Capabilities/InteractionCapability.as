/**
 * Capability that handles player interaction with interactable objects.
 * Shows prompts when near interactable objects and handles input for interaction.
 */
class UInteractionCapability : UBaseCapability
{
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

    // UI/Display settings
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Display")
    bool bShowInteractionPrompts = true;

    // Current interaction target
    AActor CurrentInteractionTarget;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive() const
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

        if (CachedPlayerController != nullptr)
        {
            SetupInput();
        }
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityDeactivated()
    {
        CleanupInput();
        
        // Clear all references
        NearbyInteractables.Empty();
        CurrentInteractionTarget = nullptr;
        CachedInputComponent = nullptr;
        CachedPlayerController = nullptr;
        CachedCharacter = nullptr;
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
            Log("No interaction available");
            return;
        }

        // Try to get interaction text from a pickup actor
        APickupActor Pickup = Cast<APickupActor>(CurrentInteractionTarget);
        if (Pickup != nullptr)
        {
            FString InteractionText = Pickup.GetInteractionText();
            Log(f"INTERACTION PROMPT: {InteractionText}");
        }
        else
        {
            Log("INTERACTION PROMPT: Press F to interact");
        }
    }

    bool TryInteractWith(AActor Target)
    {
        if (Target == nullptr)
            return false;

        // Handle pickup actors
        APickupActor Pickup = Cast<APickupActor>(Target);
        if (Pickup != nullptr)
        {
            bool bSuccess = Pickup.TryPickup(GetOwner());
            if (bSuccess)
            {
                // Remove from nearby interactables if it was consumed
                UnregisterInteractable(Target);
            }
            return bSuccess;
        }

        // Add other interactable types here in the future
        Log(f"No interaction handler for {Target.GetName()}");
        return false;
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
