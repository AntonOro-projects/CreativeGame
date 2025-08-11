class APickupActor : ABaseECSActor
{
    // Enable replication so RPCs and attachments replicate properly
    default bReplicates = true;
    default bReplicateMovement = true;

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
    UActorPickupCapability PickupCap;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Set up capability manager
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);

        // Add the pickup capability
        PickupCap = UActorPickupCapability::Get(this);
        if (PickupCap != nullptr)
        {
            Log(f"PickupActor {GetName()} initialized with actor pickup capability");
        }
        else
        {
            Log(f"Failed to get actor pickup capability for {GetName()}");
        }
    }

    UFUNCTION(BlueprintOverride)
    void EndPlay(EEndPlayReason EndPlayReason)
    {
        // Cleanup pickup capability if needed
        if (PickupCap != nullptr)
        {
            // The capability system handles cleanup automatically
        }
    }

    UFUNCTION(BlueprintCallable, Category = "Pickup")
    void ResetPickup()
    {
        if (PickupCap != nullptr)
        {
            // Reset the pickup state manually
            PickupCap.bIsCollected = false;
        }
    }
};
