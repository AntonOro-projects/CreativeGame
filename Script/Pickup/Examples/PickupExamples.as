/**
 * Example of how to make ANY actor pickupable using the PickupCapability.
 * This demonstrates the power of the capability system - any actor can become
 * a pickup simply by adding the capability and configuring it.
 */

// Example 1: Simple cube that becomes pickupable
class APickupCube : ABaseECSActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent CubeMesh;

    UCapabilityManagerComponent CachedCapabilityManager;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Set up capability manager
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);

        // Add pickup capability to make this cube pickupable
        CachedCapabilityManager.AddCapability(UPickupCapability);

        // Configure the pickup
        UPickupCapability PickupCap = UPickupCapability::Get(this);
        if (PickupCap != nullptr)
        {
            // Set what item this represents (you'd assign this in the editor)
            // PickupCap.SetPickupItem(SomeInventoryItemData);
            
            // Configure visual effects
            PickupCap.bRotatePickup = true;
            PickupCap.RotationSpeed = 45.0f;
            PickupCap.bBobUpAndDown = true;
            PickupCap.BobHeight = 10.0f;
            
            // Set interaction distance
            PickupCap.SetInteractionRadius(200.0f);
            
            // Specify which mesh component to apply effects to
            PickupCap.TargetMeshComponent = CubeMesh;
            
            Log("Pickup cube initialized - this cube is now pickupable!");
        }
    }
};

// Example 2: Environmental object that becomes pickupable
class APickupBarrel : ABaseECSActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent BarrelMesh;

    UPROPERTY(DefaultComponent, Attach = BarrelMesh)
    UStaticMeshComponent BarrelTop;

    UCapabilityManagerComponent CachedCapabilityManager;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);
        CachedCapabilityManager.AddCapability(UPickupCapability);

        UPickupCapability PickupCap = UPickupCapability::Get(this);
        if (PickupCap != nullptr)
        {
            // This barrel is reusable (like a container)
            PickupCap.bIsReusable = true;
            
            // No visual effects for environmental objects
            PickupCap.bRotatePickup = false;
            PickupCap.bBobUpAndDown = false;
            
            // Larger interaction radius for big objects
            PickupCap.SetInteractionRadius(300.0f);
            
            // Use the main mesh for any mesh-related operations
            PickupCap.TargetMeshComponent = BarrelMesh;
        }
    }
};

// Example 3: Turn any existing actor into a pickup at runtime
UFUNCTION(BlueprintCallable, Category = "Pickup Utils")
void MakeActorPickupable(AActor TargetActor, UInventoryItemData ItemData, float InteractionRadius = 150.0f)
{
    if (TargetActor == nullptr)
        return;

    // Get or create capability manager
    UCapabilityManagerComponent CapManager = UCapabilityManagerComponent::GetOrCreate(TargetActor);
    
    // Add pickup capability
    CapManager.AddCapability(UPickupCapability);
    
    // Configure it
    UPickupCapability PickupCap = UPickupCapability::Get(TargetActor);
    if (PickupCap != nullptr)
    {
        PickupCap.SetPickupItem(ItemData);
        PickupCap.SetInteractionRadius(InteractionRadius);
        
        // Try to find a mesh component automatically
        UStaticMeshComponent MeshComp = Cast<UStaticMeshComponent>(TargetActor.GetComponentByClass(UStaticMeshComponent));
        if (MeshComp != nullptr)
        {
            PickupCap.TargetMeshComponent = MeshComp;
        }
        
        Log(f"Made {TargetActor.GetName()} pickupable!");
    }
}

// Example 4: Remove pickup capability from an actor
UFUNCTION(BlueprintCallable, Category = "Pickup Utils")
void RemovePickupCapability(AActor TargetActor)
{
    if (TargetActor == nullptr)
        return;

    UPickupCapability PickupCap = UPickupCapability::Get(TargetActor);
    if (PickupCap != nullptr)
    {
        // Deactivate the capability (the exact method may vary based on your capability system)
        // You might need to use a different method based on your UCapabilityManagerComponent implementation
        Log(f"Found pickup capability on {TargetActor.GetName()} - manual removal may be needed");
    }
    else
    {
        Log(f"No pickup capability found on {TargetActor.GetName()}");
    }
}
