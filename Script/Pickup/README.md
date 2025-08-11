# Pickup Capability System

The pickup system has been completely refactored to use a capability-based architecture. This allows **any actor** in the game world to become pickupable by simply adding the `UPickupCapability` to it.

## 🎯 Key Benefits

- **Universal Pickup System**: Add pickup functionality to ANY actor
- **No Inheritance Required**: No need to inherit from specific pickup classes
- **Modular Design**: Easy to add/remove pickup behavior at runtime
- **Automatic Setup**: Handles collision, visual effects, and interaction automatically
- **Backward Compatible**: Existing PickupActor continues to work

## 🔧 How to Use

### Method 1: Add to Any Existing Actor

```angelscript
// Make any actor pickupable at runtime
void MakeActorPickupable(AActor TargetActor, UInventoryItemData ItemData)
{
    UCapabilityManagerComponent CapManager = UCapabilityManagerComponent::GetOrCreate(TargetActor);
    CapManager.AddCapability(UPickupCapability);
    
    UPickupCapability PickupCap = UPickupCapability::Get(TargetActor);
    if (PickupCap != nullptr)
    {
        PickupCap.SetPickupItem(ItemData);
        PickupCap.SetInteractionRadius(200.0f);
    }
}
```

### Method 2: Create Custom Pickupable Actors

```angelscript
class AMyPickupableObject : ABaseECSActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent ObjectMesh;

    UCapabilityManagerComponent CachedCapabilityManager;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);
        CachedCapabilityManager.AddCapability(UPickupCapability);

        UPickupCapability PickupCap = UPickupCapability::Get(this);
        if (PickupCap != nullptr)
        {
            // Configure pickup behavior
            PickupCap.bRotatePickup = true;
            PickupCap.bBobUpAndDown = true;
            PickupCap.TargetMeshComponent = ObjectMesh;
        }
    }
};
```

### Method 3: Use Existing PickupActor (Backward Compatible)

The existing `APickupActor` class now uses the capability system internally, so all your existing pickups will continue to work without changes.

## ⚙️ Configuration Options

### Visual Effects
- `bRotatePickup`: Enable/disable rotation animation
- `RotationSpeed`: Speed of rotation in degrees per second
- `bBobUpAndDown`: Enable/disable bobbing animation
- `BobHeight`: Height of bobbing motion
- `BobSpeed`: Speed of bobbing animation

### Interaction Settings
- `InteractionRadius`: Distance at which players can interact
- `bIsReusable`: Whether pickup can be used multiple times
- `ItemToPickup`: The inventory item this pickup represents

### Component Setup
- `TargetMeshComponent`: Which mesh to apply visual effects to
- `bAutoCreateCollisionSphere`: Automatically create interaction collision
- `InteractionSphere`: Manual collision sphere assignment

## 🎮 Usage Examples

### 1. Environmental Objects
Turn any decorative object into a pickup:
```angelscript
// Turn a decorative vase into a collectible
MakeActorPickupable(VaseActor, VaseItemData);
```

### 2. Dynamic Pickups
Create pickups at runtime:
```angelscript
// Spawn a coin that can be picked up
AMyPickupableObject Coin = SpawnActor<AMyPickupableObject>();
UPickupCapability PickupCap = UPickupCapability::Get(Coin);
PickupCap.SetPickupItem(CoinItemData);
```

### 3. Conditional Pickups
Make objects pickupable under certain conditions:
```angelscript
// Only make treasure pickupable after puzzle is solved
if (PuzzleSolved)
{
    MakeActorPickupable(TreasureChest, TreasureItemData);
}
```

### 4. Temporary Pickups
Objects that become non-pickupable after use:
```angelscript
UPickupCapability PickupCap = UPickupCapability::Get(KeyActor);
PickupCap.bIsReusable = false; // Single use only
```

## 🔄 Migration from Old System

If you have existing pickup code:

### Before (Old System):
```angelscript
class AMyPickup : APickupActor
{
    // Custom pickup logic mixed with base functionality
}
```

### After (New System):
```angelscript
class AMyPickup : ABaseECSActor
{
    UCapabilityManagerComponent CachedCapabilityManager;
    
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);
        CachedCapabilityManager.AddCapability(UPickupCapability);
        // Configure pickup capability...
    }
}
```

## 🎯 Advanced Features

### Custom Pickup Events
Override the `OnItemPickedUp` function in the capability:
```angelscript
class UMyCustomPickupCapability : UPickupCapability
{
    UFUNCTION(BlueprintOverride)
    void OnItemPickedUp(AActor InteractingActor, UInventoryItemData PickedUpItem)
    {
        // Custom pickup behavior
        PlayPickupSound();
        SpawnParticleEffect();
        // ... etc
    }
}
```

### Runtime Configuration
Change pickup behavior dynamically:
```angelscript
UPickupCapability PickupCap = UPickupCapability::Get(SomeActor);
PickupCap.SetInteractionRadius(500.0f); // Increase pickup range
PickupCap.bRotatePickup = false; // Stop rotation
PickupCap.SetPickupItem(NewItemData); // Change what item it gives
```

## 🏗️ Architecture Benefits

1. **Separation of Concerns**: Pickup logic is separate from actor structure
2. **Reusability**: Same capability works on any actor type  
3. **Composability**: Combine with other capabilities for complex behavior
4. **Runtime Flexibility**: Add/remove/modify pickup behavior dynamically
5. **Testing**: Easy to unit test pickup logic in isolation

## 🔧 Technical Details

- **Automatic Collision**: Creates interaction sphere if none exists
- **Mesh Detection**: Automatically finds mesh components to apply effects
- **Component Integration**: Works with existing collision and mesh components
- **Memory Efficient**: Capabilities are only created when needed
- **Performance**: Visual effects only run when capability is active

This system gives users complete control over what can be picked up in the world, making it perfect for a creative game where players should be able to interact with and collect anything they want!
