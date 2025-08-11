/**
 * Inventory Component that stores actual actors instead of data assets.
 * This allows inventory items to have their own capabilities and behavior.
 */
class UInventoryComponent : UBaseComponent
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

    // Transform for held items (relative to player) - positioned in front and slightly to the right
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Held Item")
    FTransform HeldItemTransform = FTransform(FRotator::ZeroRotator, FVector(150, 50, 0), FVector::OneVector);

    // Currently held item actor (for visual display)
    UPROPERTY(BlueprintReadOnly, Category = "Held Item")
    AActor CurrentlyHeldActor;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Initialize inventory slots
        InventorySlots.SetNum(MaxInventorySlots);
    }

    // No TickComponent override is available on this base

    UFUNCTION(BlueprintCallable)
    bool AddItemToSlot(AActor NewItem, int32 SlotIndex)
    {
        if (SlotIndex >= 0 && SlotIndex < MaxInventorySlots && NewItem != nullptr)
        {
            // If slot is occupied, fail
            if (InventorySlots[SlotIndex] != nullptr)
                return false;

            // IMMEDIATELY secure the item to prevent falling
            UPrimitiveComponent PrimComp = Cast<UPrimitiveComponent>(NewItem.GetRootComponent());
            if (PrimComp != nullptr)
            {
                PrimComp.SetSimulatePhysics(false);
                PrimComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
            }
            // Also attempt to disable on the first static mesh component (if mesh isn't root)
            UStaticMeshComponent MeshComp = Cast<UStaticMeshComponent>(NewItem.GetComponentByClass(UStaticMeshComponent));
            if (MeshComp != nullptr)
            {
                MeshComp.SetSimulatePhysics(false);
                MeshComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
            }
            NewItem.SetActorEnableCollision(false);

            InventorySlots[SlotIndex] = NewItem;
            
            // Hide the item
            HideItem(NewItem);
            
            Log(f"Added {NewItem.GetName()} to inventory slot {SlotIndex}");
            
            // Update held item (which will show it if it's the selected slot)
            UpdateHeldItem();
            
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
            
            // Restore the item's physics and show it again (for dropping)
            if (ItemToRemove != nullptr)
            {
                RestoreItemPhysics(ItemToRemove);
            }
        }
    }

    void RestoreItemPhysics(AActor Item)
    {
        if (Item != nullptr)
        {
            Log(f"Restoring physics for {Item.GetName()}");
            
            // Detach from player
            Item.DetachFromActor();
            
            // Show the item and re-enable collision
            Item.SetActorHiddenInGame(false);
            Item.SetActorEnableCollision(true);
            
            // Re-enable physics simulation
            UPrimitiveComponent PrimComp = Cast<UPrimitiveComponent>(Item.GetRootComponent());
            if (PrimComp != nullptr)
            {
                PrimComp.SetSimulatePhysics(true);
            }
            
            // Notify the item that it's no longer being held
            NotifyItemHeld(Item, false);
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
            Log(f"Hid previously held item: {CurrentlyHeldActor.GetName()}");
        }

        // Get new held item
        CurrentlyHeldActor = GetPrimaryItem();
        
        if (CurrentlyHeldActor != nullptr)
        {
            Log(f"Updating held item to: {CurrentlyHeldActor.GetName()}");
            
            // Attach to player and show
            AttachItemToPlayer(CurrentlyHeldActor);
            ShowItem(CurrentlyHeldActor);
            
            // Notify the item that it's being held
            NotifyItemHeld(CurrentlyHeldActor, true);
            
            Log(f"Item {CurrentlyHeldActor.GetName()} should now be visible and attached");
        }
        else
        {
            Log("No item to hold - hands are empty");
        }
    }

    void HideItem(AActor Item)
    {
        if (Item != nullptr)
        {
            Item.SetActorHiddenInGame(true);
            Item.SetActorEnableCollision(false);

            // Also disable physics simulation to prevent falling through floor
            UPrimitiveComponent PrimComp = Cast<UPrimitiveComponent>(Item.GetRootComponent());
            if (PrimComp != nullptr)
            {
                PrimComp.SetSimulatePhysics(false);
                PrimComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
            }
            // And on the first static mesh component if present
            UStaticMeshComponent MeshComp = Cast<UStaticMeshComponent>(Item.GetComponentByClass(UStaticMeshComponent));
            if (MeshComp != nullptr)
            {
                MeshComp.SetSimulatePhysics(false);
                MeshComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
            }
            
            // Notify the item that it's no longer being held
            NotifyItemHeld(Item, false);
        }
    }

    void ShowItem(AActor Item)
    {
        if (Item != nullptr)
        {
            Item.SetActorHiddenInGame(false);
            // Don't re-enable collision for held items - they should remain non-collidable
            // Item.SetActorEnableCollision(true);

            // Ensure physics simulation is disabled for held items
            UPrimitiveComponent PrimComp = Cast<UPrimitiveComponent>(Item.GetRootComponent());
            if (PrimComp != nullptr)
            {
                PrimComp.SetSimulatePhysics(false);
                PrimComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
            }
            // And also on the first static mesh component
            UStaticMeshComponent MeshComp = Cast<UStaticMeshComponent>(Item.GetComponentByClass(UStaticMeshComponent));
            if (MeshComp != nullptr)
            {
                MeshComp.SetSimulatePhysics(false);
                MeshComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
            }
        }
    }

    void AttachItemToPlayer(AActor Item)
    {
        if (Item != nullptr)
        {
            AActor OwnerActor = GetOwner();
            if (OwnerActor != nullptr)
            {
                Log(f"Attaching {Item.GetName()} to {OwnerActor.GetName()} at position {HeldItemTransform.Translation}");
                
                // Disable physics and collision IMMEDIATELY to prevent any falling
                UPrimitiveComponent PrimComp = Cast<UPrimitiveComponent>(Item.GetRootComponent());
                if (PrimComp != nullptr)
                {
                    PrimComp.SetSimulatePhysics(false);
                    PrimComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
                    // Ensure component is movable so transform updates apply
                    PrimComp.SetMobility(EComponentMobility::Movable);
                }
                // Also try on the first static mesh component
                UStaticMeshComponent MeshComp = Cast<UStaticMeshComponent>(Item.GetComponentByClass(UStaticMeshComponent));
                if (MeshComp != nullptr)
                {
                    MeshComp.SetSimulatePhysics(false);
                    MeshComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
                    MeshComp.SetMobility(EComponentMobility::Movable);
                }

                // Set kinematic to prevent physics issues
                Item.SetActorEnableCollision(false);
                
                // Set the position BEFORE attaching to prevent falling
                FVector PlayerLocation = OwnerActor.GetActorLocation();
                FVector TargetLocation = PlayerLocation + HeldItemTransform.Translation;
                Item.SetActorLocation(TargetLocation);
                
                // Now attach item root to the player's root component for reliable following
                USceneComponent ParentRoot = OwnerActor.GetRootComponent();
                if (ParentRoot != nullptr)
                {
                    USceneComponent ItemRoot = Item.GetRootComponent();
                    if (ItemRoot != nullptr)
                    {
                        // Force movable on root component as well
                        ItemRoot.SetMobility(EComponentMobility::Movable);
                        // Ensure relative transform is used (not absolute)
                        ItemRoot.SetAbsolute(false, false, false);
                        ItemRoot.AttachToComponent(ParentRoot);
                        ItemRoot.SetRelativeTransform(HeldItemTransform);
                    }
                    else
                    {
                        // Fallback to actor attach if no root component found (unlikely)
                        Item.AttachToActor(OwnerActor);
                        Item.SetActorRelativeTransform(HeldItemTransform);
                    }
                }
                else
                {
                    // Fallback to actor attach if owner has no root component
                    Item.AttachToActor(OwnerActor);
                    Item.SetActorRelativeTransform(HeldItemTransform);
                }
                
                // Triple-check physics is disabled after attachment
                if (PrimComp != nullptr)
                {
                    PrimComp.SetSimulatePhysics(false);
                    PrimComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
                    PrimComp.SetMobility(EComponentMobility::Movable);
                }
                if (MeshComp != nullptr)
                {
                    MeshComp.SetSimulatePhysics(false);
                    MeshComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
                    MeshComp.SetMobility(EComponentMobility::Movable);
                }
                
                Log(f"Item attached. Item location: {Item.GetActorLocation()}, Player location: {OwnerActor.GetActorLocation()}");
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

    // Ensure the held item follows the owner reliably, regardless of attachment quirks
    void SyncHeldItemToOwner()
    {
        AActor OwnerActor = GetOwner();
        if (OwnerActor == nullptr || CurrentlyHeldActor == nullptr)
            return;

        // Compute world-space position and rotation from owner's transform and the held offset
        FVector OwnerLocation = OwnerActor.GetActorLocation();
        FRotator OwnerRotation = OwnerActor.GetActorRotation();

        // Rotate the offset by the owner's rotation to get world offset
        FVector WorldOffset = OwnerRotation.RotateVector(HeldItemTransform.Translation);
        FVector TargetWorldLocation = OwnerLocation + WorldOffset;
        FRotator TargetWorldRotation = OwnerRotation + HeldItemTransform.Rotator();

        // Apply to the item's root (preferred) or the actor as fallback
        USceneComponent ItemRoot = CurrentlyHeldActor.GetRootComponent();
        if (ItemRoot != nullptr)
        {
            ItemRoot.SetWorldLocation(TargetWorldLocation);
            ItemRoot.SetWorldRotation(TargetWorldRotation);
        }
        else
        {
            CurrentlyHeldActor.SetActorLocation(TargetWorldLocation);
            CurrentlyHeldActor.SetActorRotation(TargetWorldRotation);
        }
    }
};