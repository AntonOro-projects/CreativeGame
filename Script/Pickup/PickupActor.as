class APickupActor : ABaseECSActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent Mesh;

    // Collision component for detecting nearby players
    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    USphereComponent InteractionSphere;

    // Capability manager for handling pickup functionality
    UCapabilityManagerComponent CachedCapabilityManager;

    // Pickup capability that handles all the pickup logic
    UPROPERTY()
    UPickupCapability PickupCap;

    // Legacy properties - these are now handled by the capability but kept for editor compatibility
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Pickup", meta = (DisplayName = "Item To Pickup (Legacy - Use Capability)"))
    UInventoryItemData ItemToPickup;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Set up capability manager
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);

        // Add the pickup capability
        CachedCapabilityManager.AddCapability(UPickupCapability);

        // Get reference to the pickup capability for configuration
        PickupCap = UPickupCapability::Get(this);
        if (PickupCap != nullptr)
        {
            // Transfer legacy settings to the capability
            if (ItemToPickup != nullptr)
            {
                PickupCap.SetPickupItem(ItemToPickup);
            }

            // Configure the capability to use our existing components
            PickupCap.TargetMeshComponent = Mesh;
            PickupCap.bAutoCreateCollisionSphere = false; // We already have one

            Log(f"PickupActor {GetName()} initialized with pickup capability");
        }
        else
        {
            Log(f"Failed to get pickup capability for {GetName()}");
        }
    }

    // Legacy functions for backward compatibility - these delegate to the capability
    UFUNCTION(BlueprintCallable, Category = "Pickup")
    bool TryPickup(AActor InteractingActor)
    {
        if (PickupCap != nullptr)
        {
            return PickupCap.TryPickup(InteractingActor);
        }
        return false;
    }

    UFUNCTION(BlueprintCallable, Category = "Pickup")
    FString GetInteractionText() const
    {
        if (PickupCap != nullptr)
        {
            return PickupCap.GetInteractionText();
        }
        return "Press F to interact";
    }

    UFUNCTION(BlueprintCallable, Category = "Pickup")
    bool CanBePickedUp() const
    {
        if (PickupCap != nullptr)
        {
            return PickupCap.CanBePickedUp();
        }
        return false;
    }

    UFUNCTION(BlueprintCallable, Category = "Pickup")
    void ResetPickup()
    {
        if (PickupCap != nullptr)
        {
            PickupCap.ResetPickup();
        }
    }

    // Legacy event - delegates to capability
    UFUNCTION(BlueprintCallable, Category = "Pickup")
    void OnItemPickedUp(AActor InteractingActor, UInventoryItemData PickedUpItem)
    {
        // Base implementation - override for custom behavior
        // This is now handled by the capability system
    }
};

// Test pickup asset for quick testing
asset TestPickupItem of UInventoryItemData
{
    ItemName = "Test Pickup";
    Description = "A test item that can be picked up";
    ItemCategory = "Test";
    ItemWeight = 1.0f;
    ItemRarityColor = FLinearColor(0.0f, 1.0f, 0.0f, 1.0f); // Green
}