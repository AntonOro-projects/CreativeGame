/**
 * Capability that handles visual representation of the currently equipped item.
 * In the new actor-based system, items are real actors that handle their own visuals.
 * This capability mainly monitors inventory changes and ensures proper item display.
 */
class UInventoryVisualsCapability : UBaseCapability
{
    // Cached references
    UInventoryComponent CachedInventoryComponent;
    AActor LastDisplayedItem;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive()
    {
        // Active when we have an inventory component
        return GetInventoryComponent() != nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityActivated()
    {
        // Cache references
        CachedInventoryComponent = GetInventoryComponent();
        
        // Update the initially equipped item
        UpdateEquippedItemVisuals();
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityDeactivated()
    {
        CachedInventoryComponent = nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void TickCapability(float DeltaTime)
    {
        // Check if the equipped item has changed
        if (CachedInventoryComponent != nullptr)
        {
            AActor CurrentItem = CachedInventoryComponent.GetPrimaryItem();
            if (CurrentItem != LastDisplayedItem)
            {
                UpdateEquippedItemVisuals();
                LastDisplayedItem = CurrentItem;
            }

            // Keep the held item following the player every tick
            if (CurrentItem != nullptr)
            {
                CachedInventoryComponent.SyncHeldItemToOwner();
            }
        }
    }

    void UpdateEquippedItemVisuals()
    {
        if (CachedInventoryComponent == nullptr)
            return;

        AActor CurrentItem = CachedInventoryComponent.GetPrimaryItem();
        
        if (CurrentItem != nullptr)
        {
            // In the actor-based system, the inventory component handles attachment and visibility
            // The item actor itself manages its visual representation
            Log("Now displaying: " + CurrentItem.GetName());
        }
        else
        {
            Log("No item currently equipped");
        }
    }

    UInventoryComponent GetInventoryComponent()
    {
        if (CachedInventoryComponent == nullptr && GetOwner() != nullptr)
        {
            CachedInventoryComponent = UInventoryComponent::Get(GetOwner());
        }
        return CachedInventoryComponent;
    }
};
