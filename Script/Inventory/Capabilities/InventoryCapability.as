class UInventoryCapability : UBaseCapability
{
    int Count = 0;
    
	UFUNCTION(BlueprintOverride)
	bool ShouldBeActive() const
	{
        if (Count < 10)
		{
			return true;
		}
		return false;
	}

    
	UFUNCTION(BlueprintOverride)
	void TickCapability(float DeltaTime)
	{
        Count++;
        if (Count > 10)
        {
            UCapabilityManagerComponent CapabilityManagerComponent = UCapabilityManagerComponent::Get(GetOwner());
            CapabilityManagerComponent.UpdateCapabilityStates();
        }
        Log(f"TickCapability is active and ticking. Count: {Count}");
	}
};