class UInventoryInputCapability : UBaseCapability
{
    // Cached references
    UInventoryComponent CachedInventoryComponent;
    UEnhancedInputComponent CachedInputComponent;
    ABaseECSPlayerController CachedPlayerController;
    ABaseECSCharacter CachedCharacter;
    UPlayerHUDCapability CachedHUDCapability;

    // For tracking inventory changes
    UInventoryItemData LastKnownItem;
    int32 LastKnownSlot = -1;

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

        // Get HUD capability for displaying inventory info
        CachedHUDCapability = UPlayerHUDCapability::Get(GetOwner());

        if (CachedPlayerController != nullptr)
        {
            SetupInput();
        }

        // Update HUD with initial inventory state
        UpdateInventoryHUD();
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
        CachedHUDCapability = nullptr;
        
        // Clear tracking variables
        LastKnownItem = nullptr;
        LastKnownSlot = -1;
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
            
            // Update HUD instead of console logging
            UpdateInventoryHUD();

            // Notify other systems about inventory selection change
            OnInventorySelectionChanged(PreviousSlot, SlotIndex, SelectedItem);
        }
    }

    void UpdateInventoryHUD()
    {
        // Try to get HUD capability if we don't have it cached
        if (CachedHUDCapability == nullptr)
        {
            CachedHUDCapability = UPlayerHUDCapability::Get(GetOwner());
        }
        
        if (CachedHUDCapability != nullptr && CachedInventoryComponent != nullptr)
        {
            int32 SelectedSlot = CachedInventoryComponent.GetSelectedSlotIndex();
            UInventoryItemData SelectedItem = CachedInventoryComponent.GetPrimaryItem();
            
            FString ItemName = "Empty";
            if (SelectedItem != nullptr)
            {
                ItemName = SelectedItem.GetDisplayName();
            }
            
            CachedHUDCapability.UpdateInventoryDisplay(SelectedSlot + 1, ItemName);
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
        // Check if inventory has changed and update HUD if needed
        // This handles cases where items are added/removed outside of input (like pickups)
        if (CachedInventoryComponent != nullptr)
        {
            UInventoryItemData CurrentItem = CachedInventoryComponent.GetPrimaryItem();
            int32 CurrentSlot = CachedInventoryComponent.GetSelectedSlotIndex();
            
            // Update HUD if the selected slot or its contents changed
            if (CurrentItem != LastKnownItem || CurrentSlot != LastKnownSlot)
            {
                UpdateInventoryHUD();
                LastKnownItem = CurrentItem;
                LastKnownSlot = CurrentSlot;
            }
        }
    }
};