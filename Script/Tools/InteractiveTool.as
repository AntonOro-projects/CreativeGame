/**
 * Example interactive tool that can be picked up and used
 */
class AInteractiveTool : ABaseECSActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent Mesh;

    // Collision component for pickup detection
    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    USphereComponent InteractionSphere;

    UCapabilityManagerComponent CachedCapabilityManager;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Set up capability manager
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);

        // Add pickup capability so this can be picked up
        CachedCapabilityManager.AddCapability(UActorPickupCapability);

        // Add interactive capability so this responds to input when held
        CachedCapabilityManager.AddCapability(UActorInteractiveItemCapability);

        Log("Interactive tool " + GetName() + " initialized");
    }
};
