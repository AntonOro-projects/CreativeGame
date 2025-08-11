/**
 * Enhanced Inventory Component that stores actual actors instead of data assets.
 * This allows inventory items to have their own capabilities and behavior.
 */
class UActorInventoryComponent : UBaseComponent
{
    // Inventory slots holding actual actors (5 slots for keyboard keys 1-5)
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Inventory")
    TArray<AActor> InventorySlots;

    // Currently selected/primary item slot index (0-4 for keys 1-5)
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Inventory")
    int32 SelectedSlotIndex = 0;

    // Maximum number of inventory slots
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Inventory")
    int32 MaxInventorySlots = 5;

    // Transform for held items (relative to player)
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Held Item")
    FTransform HeldItemTransform = FTransform(FRotator::ZeroRotator, FVector(100, 0, 0), FVector::OneVector);

    // Currently held item actor (for visual display)
    UPROPERTY(BlueprintReadOnly, Category = "Held Item")
    AActor CurrentlyHeldActor;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Initialize inventory slots
        InventorySlots.SetNum(MaxInventorySlots);
    }

    UFUNCTION(BlueprintCallable)
    bool AddItemToSlot(AActor NewItem, int32 SlotIndex)
    {
        if (SlotIndex >= 0 && SlotIndex < MaxInventorySlots && NewItem != nullptr)
        {
            // If slot is occupied, fail
            if (InventorySlots[SlotIndex] != nullptr)
                return false;

            InventorySlots[SlotIndex] = NewItem;
            
            // Hide the item and disable collision
            HideItem(NewItem);
            
            // If this is the selected slot, update held item
            if (SlotIndex == SelectedSlotIndex)
            {
                UpdateHeldItem();
            }
            
            return true;
        }
        return false;
    }

    UFUNCTION(BlueprintCallable)
    bool AddItemToFirstAvailableSlot(AActor NewItem)
    {
        for (int32 i = 0; i < MaxInventorySlots; i++)
        {
            if (InventorySlots[i] == nullptr)
            {
                return AddItemToSlot(NewItem, i);
            }
        }
        return false; // No available slots
    }

    UFUNCTION(BlueprintCallable)
    void RemoveItemFromSlot(int32 SlotIndex)
    {
        if (SlotIndex >= 0 && SlotIndex < MaxInventorySlots)
        {
            AActor ItemToRemove = InventorySlots[SlotIndex];
            InventorySlots[SlotIndex] = nullptr;
            
            // If this was the held item, update
            if (SlotIndex == SelectedSlotIndex)
            {
                UpdateHeldItem();
            }
            
            // Show the item again (for dropping)
            if (ItemToRemove != nullptr)
            {
                ShowItem(ItemToRemove);
            }
        }
    }

    UFUNCTION(BlueprintCallable)
    AActor GetItemInSlot(int32 SlotIndex) const
    {
        if (SlotIndex >= 0 && SlotIndex < MaxInventorySlots)
        {
            return InventorySlots[SlotIndex];
        }
        return nullptr;
    }

    UFUNCTION(BlueprintCallable)
    AActor GetPrimaryItem() const
    {
        return GetItemInSlot(SelectedSlotIndex);
    }

    UFUNCTION(BlueprintCallable)
    void SetSelectedSlot(int32 NewSlotIndex)
    {
        if (NewSlotIndex >= 0 && NewSlotIndex < MaxInventorySlots && NewSlotIndex != SelectedSlotIndex)
        {
            SelectedSlotIndex = NewSlotIndex;
            UpdateHeldItem();
        }
    }

    UFUNCTION(BlueprintCallable)
    int32 GetSelectedSlotIndex() const
    {
        return SelectedSlotIndex;
    }

    UFUNCTION(BlueprintCallable)
    TArray<AActor> GetAllItems() const
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

    void UpdateHeldItem()
    {
        // Hide current held item
        if (CurrentlyHeldActor != nullptr)
        {
            HideItem(CurrentlyHeldActor);
        }

        // Get new held item
        CurrentlyHeldActor = GetPrimaryItem();
        
        if (CurrentlyHeldActor != nullptr)
        {
            // Attach to player and show
            AttachItemToPlayer(CurrentlyHeldActor);
            ShowItem(CurrentlyHeldActor);
            
            // Notify the item that it's being held
            NotifyItemHeld(CurrentlyHeldActor, true);
        }
    }

    void HideItem(AActor Item)
    {
        if (Item != nullptr)
        {
            Item.SetActorHiddenInGame(true);
            Item.SetActorEnableCollision(false);
            
            // Notify the item that it's no longer being held
            NotifyItemHeld(Item, false);
        }
    }

    void ShowItem(AActor Item)
    {
        if (Item != nullptr)
        {
            Item.SetActorHiddenInGame(false);
            Item.SetActorEnableCollision(true);
        }
    }

    void AttachItemToPlayer(AActor Item)
    {
        if (Item != nullptr)
        {
            AActor OwnerActor = GetOwner();
            if (OwnerActor != nullptr)
            {
                // Attach to player at the held item transform
                Item.AttachToActor(OwnerActor);
                Item.SetActorRelativeTransform(HeldItemTransform);
            }
        }
    }

    void NotifyItemHeld(AActor Item, bool bIsHeld)
    {
        if (Item == nullptr)
            return;

        // Try to notify any relevant capabilities on the item
        UCapabilityManagerComponent ItemCapabilityManager = UCapabilityManagerComponent::Get(Item);
        if (ItemCapabilityManager != nullptr)
        {
            // Get all capabilities and notify them about being held/unheld
            TArray<UBaseCapability> Capabilities = ItemCapabilityManager.GetAllCapabilities();
            for (UBaseCapability Capability : Capabilities)
            {
                // Try to cast to a holdable item capability interface
                UHoldableItemCapability HoldableCapability = Cast<UHoldableItemCapability>(Capability);
                if (HoldableCapability != nullptr)
                {
                    if (bIsHeld)
                    {
                        HoldableCapability.OnItemHeld(GetOwner());
                    }
                    else
                    {
                        HoldableCapability.OnItemUnheld();
                    }
                }
            }
        }
    }
};
