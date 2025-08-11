class UCapabilityInspectorCapability : UBaseCapability
{

    ABaseECSCharacter CachedCharacter;
    UInventoryComponent CachedInventoryComponent;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive()
    {
        if (CachedCharacter == nullptr)
        {
            CachedCharacter = Cast<ABaseECSCharacter>(GetOwner());
        }

        if (CachedCharacter != nullptr && CachedInventoryComponent == nullptr)
        {
            CachedInventoryComponent = UInventoryComponent::Get(CachedCharacter);
        }

        if (CachedInventoryComponent != nullptr)
        {
            if (CachedInventoryComponent.GetPrimaryItem().Name == GetOwner().Name)
            {
                return true;
            }
        }

        return false;
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityActivated()
    {

    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityDeactivated()
    {

    }
};
