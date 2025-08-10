/**
 * Utility capability for testing and managing inventory items.
 * This capability provides helper functions to add test items to the inventory.
 */
class UInventoryTestCapability : UBaseCapability
{
    // Test items for demonstration
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Test Items")
    TArray<UInventoryItemData> TestItems;

    // Whether to automatically add test items on start
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Test Items")
    bool bAutoAddTestItems = false;

    UInventoryComponent CachedInventoryComponent;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive() const
    {
        return GetInventoryComponent() != nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityActivated()
    {
        CachedInventoryComponent = GetInventoryComponent();
        
        if (bAutoAddTestItems && CachedInventoryComponent != nullptr)
        {
            AddTestItemsToInventory();
        }
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityDeactivated()
    {
        CachedInventoryComponent = nullptr;
    }

    UFUNCTION(BlueprintCallable, Category = "Inventory Test")
    void AddTestItemsToInventory()
    {
        if (CachedInventoryComponent == nullptr)
            return;

        for (int32 i = 0; i < TestItems.Num() && i < CachedInventoryComponent.MaxInventorySlots; i++)
        {
            if (TestItems[i] != nullptr)
            {
                CachedInventoryComponent.AddItemToSlot(TestItems[i], i);
                Log(f"Added test item '{TestItems[i].GetDisplayName()}' to slot {i + 1}");
            }
        }
    }

    UFUNCTION(BlueprintCallable, Category = "Inventory Test")
    void ClearInventory()
    {
        if (CachedInventoryComponent == nullptr)
            return;

        for (int32 i = 0; i < CachedInventoryComponent.MaxInventorySlots; i++)
        {
            CachedInventoryComponent.RemoveItemFromSlot(i);
        }
        Log("Inventory cleared");
    }

    UFUNCTION(BlueprintCallable, Category = "Inventory Test")
    void PrintInventoryStatus()
    {
        if (CachedInventoryComponent == nullptr)
        {
            Log("No inventory component found");
            return;
        }

        Log("=== Inventory Status ===");
        Log(f"Selected Slot: {CachedInventoryComponent.GetSelectedSlotIndex() + 1}");
        
        for (int32 i = 0; i < CachedInventoryComponent.MaxInventorySlots; i++)
        {
            UInventoryItemData Item = CachedInventoryComponent.GetItemInSlot(i);
            if (Item != nullptr)
            {
                FString SlotInfo = f"Slot {i + 1}: {Item.GetDisplayName()}";
                if (i == CachedInventoryComponent.GetSelectedSlotIndex())
                {
                    SlotInfo += " (SELECTED)";
                }
                Log(SlotInfo);
            }
            else
            {
                FString SlotInfo = f"Slot {i + 1}: Empty";
                if (i == CachedInventoryComponent.GetSelectedSlotIndex())
                {
                    SlotInfo += " (SELECTED)";
                }
                Log(SlotInfo);
            }
        }

        UInventoryItemData PrimaryItem = CachedInventoryComponent.GetPrimaryItem();
        if (PrimaryItem != nullptr)
        {
            Log(f"Primary Item: {PrimaryItem.GetDisplayName()}");
            Log(f"Primary Item Description: {PrimaryItem.GetDisplayDescription()}");
        }
        else
        {
            Log("No primary item equipped");
        }
        Log("========================");
    }

    UInventoryComponent GetInventoryComponent() const
    {
        return UInventoryComponent::Get(GetOwner());
    }

    UFUNCTION(BlueprintOverride)
    void TickCapability(float DeltaTime)
    {
        // This capability doesn't need to tick
    }
};
