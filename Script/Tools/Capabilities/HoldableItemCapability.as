/**
 * Interface/Base class for capabilities that want to know when their item is held/unheld
 */
class UHoldableItemCapability : UBaseCapability
{
    // Called when the item is picked up and held by a player
    UFUNCTION(BlueprintCallable, Category = "Holdable Item")
    void OnItemHeld(AActor HoldingActor)
    {
        // Override in derived classes
        OnItemHeldImpl(HoldingActor);
    }

    // Called when the item is no longer being held
    UFUNCTION(BlueprintCallable, Category = "Holdable Item")
    void OnItemUnheld()
    {
        // Override in derived classes
        OnItemUnheldImpl();
    }

    // Override these in derived classes for custom behavior
    void OnItemHeldImpl(AActor HoldingActor)
    {
        // Default implementation - do nothing
    }

    void OnItemUnheldImpl()
    {
        // Default implementation - do nothing
    }
};
