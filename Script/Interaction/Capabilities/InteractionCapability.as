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
    UPlayerHUDCapability CachedHUDCapability;

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

        // Get HUD capability for displaying interaction prompts
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
        
        // Clear all references
        NearbyInteractables.Empty();
        CurrentInteractionTarget = nullptr;
        CachedInputComponent = nullptr;
        CachedPlayerController = nullptr;
        CachedCharacter = nullptr;
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

        // Try to get interaction text from a pickup actor
        APickupActor Pickup = Cast<APickupActor>(CurrentInteractionTarget);
        FString InteractionText;
        
        if (Pickup != nullptr)
        {
            InteractionText = Pickup.GetInteractionText();
        }
        else
        {
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
