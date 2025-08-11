/**
 * Interactive Item Capability for Actor-Based Inventory System
 * This capability is attached to item actors and provides input handling when the item is held
 */
class UActorInteractiveItemCapability : UHoldableItemCapability
{
    // The player currently holding this item
    AActor HoldingPlayer;
    APlayerController CachedPlayerController;
    UEnhancedInputComponent CachedInputComponent;

    // Input actions - these should be assigned in Blueprint or editor
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input")
    UInputAction LeftMouseAction;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input")
    UInputAction RightMouseAction;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input")
    UInputMappingContext InteractiveItemInputContext;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive()
    {
        // This capability should be active when the item is being held
        return HoldingPlayer != nullptr;
    }

    void OnItemHeldImpl(AActor HoldingActor) override
    {
        HoldingPlayer = HoldingActor;
        
        // Get player controller
        ABaseECSCharacter Character = Cast<ABaseECSCharacter>(HoldingActor);
        if (Character != nullptr)
        {
            CachedPlayerController = Cast<APlayerController>(Character.GetController());
        }
        
        SetupInput();
        
        Print("Item " + GetOwner().GetName() + " is now being held by " + HoldingActor.GetName());
    }

    void OnItemUnheldImpl() override
    {
        CleanupInput();
        
        Print("Item " + GetOwner().GetName() + " is no longer being held");
        
        HoldingPlayer = nullptr;
        CachedPlayerController = nullptr;
    }

    void SetupInput()
    {
        if (CachedPlayerController == nullptr)
            return;

        // Create and set up enhanced input component
        CachedInputComponent = UEnhancedInputComponent::Create(CachedPlayerController);
        CachedPlayerController.PushInputComponent(CachedInputComponent);

        // Add mapping context if provided
        if (InteractiveItemInputContext != nullptr)
        {
            UEnhancedInputLocalPlayerSubsystem EnhancedInputSubsystem = UEnhancedInputLocalPlayerSubsystem::Get(CachedPlayerController);
            if (EnhancedInputSubsystem != nullptr)
            {
                EnhancedInputSubsystem.AddMappingContext(InteractiveItemInputContext, 3, FModifyContextOptions());
            }
        }

        // Bind input actions
        if (LeftMouseAction != nullptr)
        {
            CachedInputComponent.BindAction(LeftMouseAction, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"OnLeftMousePressed"));
            CachedInputComponent.BindAction(LeftMouseAction, ETriggerEvent::Completed, FEnhancedInputActionHandlerDynamicSignature(this, n"OnLeftMouseReleased"));
        }

        if (RightMouseAction != nullptr)
        {
            CachedInputComponent.BindAction(RightMouseAction, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"OnRightMousePressed"));
            CachedInputComponent.BindAction(RightMouseAction, ETriggerEvent::Completed, FEnhancedInputActionHandlerDynamicSignature(this, n"OnRightMouseReleased"));
        }
    }

    void CleanupInput()
    {
        if (CachedPlayerController != nullptr && InteractiveItemInputContext != nullptr)
        {
            UEnhancedInputLocalPlayerSubsystem EnhancedInputSubsystem = UEnhancedInputLocalPlayerSubsystem::Get(CachedPlayerController);
            if (EnhancedInputSubsystem != nullptr)
            {
                EnhancedInputSubsystem.RemoveMappingContext(InteractiveItemInputContext, FModifyContextOptions());
            }
        }

        if (CachedInputComponent != nullptr && CachedPlayerController != nullptr)
        {
            CachedPlayerController.PopInputComponent(CachedInputComponent);
            CachedInputComponent = nullptr;
        }
    }

    UFUNCTION()
    void OnLeftMousePressed(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, UInputAction SourceAction)
    {
        Print("Left mouse button pressed on item: " + GetOwner().GetName());
        HandleLeftClick(ActionValue);
    }

    UFUNCTION()
    void OnLeftMouseReleased(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, UInputAction SourceAction)
    {
        Print("Left mouse button released on item: " + GetOwner().GetName());
        HandleLeftClickRelease(ActionValue);
    }

    UFUNCTION()
    void OnRightMousePressed(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, UInputAction SourceAction)
    {
        Print("Right mouse button pressed on item: " + GetOwner().GetName());
        HandleRightClick(ActionValue);
    }

    UFUNCTION()
    void OnRightMouseReleased(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, UInputAction SourceAction)
    {
        Print("Right mouse button released on item: " + GetOwner().GetName());
        HandleRightClickRelease(ActionValue);
    }

    // Override these methods in derived classes for specific item behavior
    void HandleLeftClick(FInputActionValue ActionValue)
    {
        // Default implementation - override in derived classes
        Print("Left click action for " + GetOwner().GetName());
    }

    void HandleLeftClickRelease(FInputActionValue ActionValue)
    {
        // Default implementation - override in derived classes
    }

    void HandleRightClick(FInputActionValue ActionValue)
    {
        // Default implementation - override in derived classes
        Print("Right click action for " + GetOwner().GetName());
    }

    void HandleRightClickRelease(FInputActionValue ActionValue)
    {
        // Default implementation - override in derived classes
    }

    // Helper to get the player holding this item
    AActor GetHoldingPlayer() const
    {
        return HoldingPlayer;
    }
};
