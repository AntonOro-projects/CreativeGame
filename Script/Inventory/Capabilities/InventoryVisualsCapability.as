/**
 * Capability that handles visual representation of the currently equipped item.
 * This capability manages spawning and updating the mesh for the primary inventory item.
 */
class UInventoryVisualsCapability : UBaseCapability
{
    // The mesh component that displays the equipped item
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visuals")
    UStaticMeshComponent EquippedItemMesh;

    // Where to attach the equipped item (usually to a hand bone or socket)
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visuals")
    FName AttachmentSocketName = FName("hand_r");

    // Cached references
    UInventoryComponent CachedInventoryComponent;
    USkeletalMeshComponent CachedOwnerMesh;
    UStaticMeshComponent CachedOwnerStaticMesh;
    UInventoryItemData CurrentDisplayedItem;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive() const
    {
        // Active when we have an inventory component
        return GetInventoryComponent() != nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityActivated()
    {
        // Cache references
        CachedInventoryComponent = GetInventoryComponent();
        
        // Try to find a mesh component to attach to
        AActor OwnerActor = GetOwner();
        if (OwnerActor != nullptr)
        {
            CachedOwnerMesh = Cast<USkeletalMeshComponent>(OwnerActor.GetComponentByClass(USkeletalMeshComponent));
            if (CachedOwnerMesh == nullptr)
            {
                CachedOwnerStaticMesh = Cast<UStaticMeshComponent>(OwnerActor.GetComponentByClass(UStaticMeshComponent));
            }
        }

        // Create the equipped item mesh component
        if (EquippedItemMesh == nullptr && OwnerActor != nullptr)
        {
            EquippedItemMesh = UStaticMeshComponent::Create(OwnerActor);
            // Note: Attachment will be handled manually in UpdateEquippedItemVisuals
        }

        // Initialize with current item
        UpdateEquippedItemVisuals();
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityDeactivated()
    {
        // Clean up the equipped item mesh
        if (EquippedItemMesh != nullptr)
        {
            EquippedItemMesh.DestroyComponent();
            EquippedItemMesh = nullptr;
        }

        // Clear cached references
        CachedInventoryComponent = nullptr;
        CachedOwnerMesh = nullptr;
        CachedOwnerStaticMesh = nullptr;
        CurrentDisplayedItem = nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void TickCapability(float DeltaTime)
    {
        // Check if the equipped item has changed
        if (CachedInventoryComponent != nullptr)
        {
            UInventoryItemData CurrentItem = CachedInventoryComponent.GetPrimaryItem();
            if (CurrentItem != CurrentDisplayedItem)
            {
                UpdateEquippedItemVisuals();
            }
        }
    }

    USceneComponent GetAttachmentComponent() const
    {
        if (CachedOwnerMesh != nullptr)
        {
            return CachedOwnerMesh;
        }
        else if (CachedOwnerStaticMesh != nullptr)
        {
            return CachedOwnerStaticMesh;
        }
        else
        {
            // Fallback to root component
            AActor OwnerActor = GetOwner();
            if (OwnerActor != nullptr)
            {
                return OwnerActor.GetRootComponent();
            }
        }
        return nullptr;
    }

    void UpdateEquippedItemVisuals()
    {
        if (CachedInventoryComponent == nullptr || EquippedItemMesh == nullptr)
            return;

        UInventoryItemData NewItem = CachedInventoryComponent.GetPrimaryItem();
        CurrentDisplayedItem = NewItem;

        if (NewItem != nullptr && NewItem.HasValidMesh())
        {
            // Set the mesh
            EquippedItemMesh.SetStaticMesh(NewItem.ItemMesh);
            
            // Set the material if provided
            if (NewItem.ItemMaterial != nullptr)
            {
                EquippedItemMesh.SetMaterial(0, NewItem.ItemMaterial);
            }

            // Apply the transform
            FTransform ItemTransform = NewItem.GetHeldItemTransform();
            EquippedItemMesh.SetRelativeTransform(ItemTransform);

            // Make sure it's visible
            EquippedItemMesh.SetVisibility(true);
            EquippedItemMesh.SetHiddenInGame(false);

            Log(f"Equipped item: {NewItem.GetDisplayName()}");
        }
        else
        {
            // No item or invalid mesh - hide the component
            EquippedItemMesh.SetVisibility(false);
            EquippedItemMesh.SetHiddenInGame(true);
            EquippedItemMesh.SetStaticMesh(nullptr);

            if (NewItem == nullptr)
            {
                Log("No item equipped");
            }
            else
            {
                Log(f"Item {NewItem.GetDisplayName()} has no valid mesh");
            }
        }
    }

    UInventoryComponent GetInventoryComponent() const
    {
        return UInventoryComponent::Get(GetOwner());
    }

    // Utility functions for external access
    UFUNCTION(BlueprintCallable, Category = "Inventory Visuals")
    UStaticMeshComponent GetEquippedItemMeshComponent() const
    {
        return EquippedItemMesh;
    }

    UFUNCTION(BlueprintCallable, Category = "Inventory Visuals")
    UInventoryItemData GetCurrentDisplayedItem() const
    {
        return CurrentDisplayedItem;
    }

    UFUNCTION(BlueprintCallable, Category = "Inventory Visuals")
    void ForceUpdateVisuals()
    {
        UpdateEquippedItemVisuals();
    }
};
