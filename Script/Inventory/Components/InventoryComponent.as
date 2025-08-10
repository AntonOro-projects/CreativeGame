class UInventoryComponent : UBaseComponent
{
    // Inventory slots (5 slots for keyboard keys 1-5)
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Inventory")
    TArray<UInventoryItemData> InventorySlots;

    // Currently selected/primary item slot index (0-4 for keys 1-5)
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Inventory")
    int32 SelectedSlotIndex = 0;

    // Maximum number of inventory slots
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Inventory")
    int32 MaxInventorySlots = 5;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Initialize inventory slots
        InventorySlots.SetNum(MaxInventorySlots);
    }

    UFUNCTION(BlueprintCallable)
    bool AddItemToSlot(UInventoryItemData NewItem, int32 SlotIndex)
    {
        if (SlotIndex >= 0 && SlotIndex < MaxInventorySlots)
        {
            InventorySlots[SlotIndex] = NewItem;
            return true;
        }
        return false;
    }

    UFUNCTION(BlueprintCallable)
    bool AddItemToFirstAvailableSlot(UInventoryItemData NewItem)
    {
        for (int32 i = 0; i < MaxInventorySlots; i++)
        {
            if (InventorySlots[i] == nullptr)
            {
                InventorySlots[i] = NewItem;
                return true;
            }
        }
        return false; // No available slots
    }

    UFUNCTION(BlueprintCallable)
    void RemoveItemFromSlot(int32 SlotIndex)
    {
        if (SlotIndex >= 0 && SlotIndex < MaxInventorySlots)
        {
            InventorySlots[SlotIndex] = nullptr;
        }
    }

    UFUNCTION(BlueprintCallable)
    UInventoryItemData GetItemInSlot(int32 SlotIndex) const
    {
        if (SlotIndex >= 0 && SlotIndex < MaxInventorySlots)
        {
            return InventorySlots[SlotIndex];
        }
        return nullptr;
    }

    UFUNCTION(BlueprintCallable)
    UInventoryItemData GetPrimaryItem() const
    {
        return GetItemInSlot(SelectedSlotIndex);
    }

    UFUNCTION(BlueprintCallable)
    void SetSelectedSlot(int32 NewSlotIndex)
    {
        if (NewSlotIndex >= 0 && NewSlotIndex < MaxInventorySlots)
        {
            SelectedSlotIndex = NewSlotIndex;
        }
    }

    UFUNCTION(BlueprintCallable)
    int32 GetSelectedSlotIndex() const
    {
        return SelectedSlotIndex;
    }

    UFUNCTION(BlueprintCallable)
    TArray<UInventoryItemData> GetAllItems() const
    {
        return InventorySlots;
    }

    UFUNCTION(BlueprintCallable)
    bool IsSlotEmpty(int32 SlotIndex) const
    {
        if (SlotIndex >= 0 && SlotIndex < MaxInventorySlots)
        {
            return InventorySlots[SlotIndex] == nullptr;
        }
        return true;
    }

    UFUNCTION(BlueprintCallable)
    int32 GetEmptySlotCount() const
    {
        int32 EmptyCount = 0;
        for (int32 i = 0; i < MaxInventorySlots; i++)
        {
            if (InventorySlots[i] == nullptr)
            {
                EmptyCount++;
            }
        }
        return EmptyCount;
    }
};