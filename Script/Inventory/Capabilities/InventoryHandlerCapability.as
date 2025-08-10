class UInventoryInputCapability : UBaseCapability
{
    // Cached references
    UInventoryComponent CachedInventoryComponent;
    UEnhancedInputComponent CachedInputComponent;
    ABaseECSPlayerController CachedPlayerController;
    ABaseECSCharacter CachedCharacter;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive() const
    {
        // Always active when we have a valid inventory component
        return GetInventoryComponent() != nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityActivated()
    {
        // Cache references
        CachedInventoryComponent = GetInventoryComponent();
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
        // Clean up input bindings
        CleanupInput();
        
        // Clear cached references
        CachedInventoryComponent = nullptr;
        CachedInputComponent = nullptr;
        CachedPlayerController = nullptr;
        CachedCharacter = nullptr;
    }

    void SetupInput()
    {
        if (CachedPlayerController == nullptr || CachedCharacter == nullptr)
            return;

        // Create and set up enhanced input component
        CachedInputComponent = UEnhancedInputComponent::Create(CachedPlayerController);
        CachedPlayerController.PushInputComponent(CachedInputComponent);

        // Get input actions and mapping context from the character
        // We need to cast to the specific character type to access the input properties
        ANormalPlayerCharacter PlayerCharacter = Cast<ANormalPlayerCharacter>(CachedCharacter);
        if (PlayerCharacter == nullptr)
        {
            Log("Failed to cast character to ANormalPlayerCharacter");
            return;
        }

        // Add mapping context if provided
        if (PlayerCharacter.InventoryInputContext != nullptr)
        {
            UEnhancedInputLocalPlayerSubsystem EnhancedInputSubsystem = UEnhancedInputLocalPlayerSubsystem::Get(CachedPlayerController);
            if (EnhancedInputSubsystem != nullptr)
            {
                EnhancedInputSubsystem.AddMappingContext(PlayerCharacter.InventoryInputContext, 1, FModifyContextOptions());
            }
        }

        // Bind input actions
        if (PlayerCharacter.SelectSlot1Action != nullptr)
            CachedInputComponent.BindAction(PlayerCharacter.SelectSlot1Action, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"SelectSlot1"));
        
        if (PlayerCharacter.SelectSlot2Action != nullptr)
            CachedInputComponent.BindAction(PlayerCharacter.SelectSlot2Action, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"SelectSlot2"));
        
        if (PlayerCharacter.SelectSlot3Action != nullptr)
            CachedInputComponent.BindAction(PlayerCharacter.SelectSlot3Action, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"SelectSlot3"));
        
        if (PlayerCharacter.SelectSlot4Action != nullptr)
            CachedInputComponent.BindAction(PlayerCharacter.SelectSlot4Action, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"SelectSlot4"));
        
        if (PlayerCharacter.SelectSlot5Action != nullptr)
            CachedInputComponent.BindAction(PlayerCharacter.SelectSlot5Action, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"SelectSlot5"));
    }

    void CleanupInput()
    {
        if (CachedPlayerController != nullptr && CachedCharacter != nullptr)
        {
            ANormalPlayerCharacter PlayerCharacter = Cast<ANormalPlayerCharacter>(CachedCharacter);
            if (PlayerCharacter != nullptr && PlayerCharacter.InventoryInputContext != nullptr)
            {
                UEnhancedInputLocalPlayerSubsystem EnhancedInputSubsystem = UEnhancedInputLocalPlayerSubsystem::Get(CachedPlayerController);
                if (EnhancedInputSubsystem != nullptr)
                {
                    EnhancedInputSubsystem.RemoveMappingContext(PlayerCharacter.InventoryInputContext, FModifyContextOptions());
                }
            }
        }

        if (CachedInputComponent != nullptr && CachedPlayerController != nullptr)
        {
            CachedPlayerController.PopInputComponent(CachedInputComponent);
            CachedInputComponent = nullptr;
        }
    }

    UInventoryComponent GetInventoryComponent() const
    {
        return UInventoryComponent::Get(GetOwner());
    }

    // Input action handlers
    UFUNCTION()
    void SelectSlot1(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        SelectInventorySlot(0);
    }

    UFUNCTION()
    void SelectSlot2(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        SelectInventorySlot(1);
    }

    UFUNCTION()
    void SelectSlot3(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        SelectInventorySlot(2);
    }

    UFUNCTION()
    void SelectSlot4(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        SelectInventorySlot(3);
    }

    UFUNCTION()
    void SelectSlot5(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
    {
        SelectInventorySlot(4);
    }

    void SelectInventorySlot(int32 SlotIndex)
    {
        if (CachedInventoryComponent != nullptr)
        {
            int32 PreviousSlot = CachedInventoryComponent.GetSelectedSlotIndex();
            CachedInventoryComponent.SetSelectedSlot(SlotIndex);
            
            UInventoryItemData SelectedItem = CachedInventoryComponent.GetPrimaryItem();
            
            Log(f"Selected inventory slot {SlotIndex + 1}");
            if (SelectedItem != nullptr)
            {
                Log(f"Selected item: {SelectedItem.GetDisplayName()}");
            }
            else
            {
                Log("Selected slot is empty");
            }

            // Notify other systems about inventory selection change
            OnInventorySelectionChanged(PreviousSlot, SlotIndex, SelectedItem);
        }
    }

    // Override this to add custom logic when inventory selection changes
    UFUNCTION(BlueprintCallable, Category = "Inventory")
    void OnInventorySelectionChanged(int32 PreviousSlot, int32 NewSlot, UInventoryItemData SelectedItem)
    {
        // Base implementation - override in derived classes for custom behavior
    }

    UFUNCTION(BlueprintOverride)
    void TickCapability(float DeltaTime)
    {
        // This capability doesn't need to tick continuously
        // Input handling is event-driven
    }
};