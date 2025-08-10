class APickupActor : ABaseECSActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent Mesh;

    // Collision component for detecting nearby players
    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    USphereComponent InteractionSphere;

    // The item this pickup represents
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Pickup")
    UInventoryItemData ItemToPickup;

    // Interaction distance
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Pickup")
    float InteractionRadius = 150.0f;

    // Whether this pickup can be picked up multiple times
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Pickup")
    bool bIsReusable = false;

    // Whether this pickup has been collected
    UPROPERTY(BlueprintReadOnly, Category = "Pickup")
    bool bIsCollected = false;

    // Visual feedback settings
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    bool bRotatePickup = true;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    float RotationSpeed = 90.0f; // degrees per second

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    bool bBobUpAndDown = true;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    float BobHeight = 20.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    float BobSpeed = 2.0f;

    // Internal state for visual effects
    float OriginalZ;
    float TimeAccumulator = 0.0f;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Set up the interaction sphere
        InteractionSphere.SetSphereRadius(InteractionRadius);
        InteractionSphere.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
        // Note: Collision channels will need to be set up in editor or with specific values

        // Store original Z position for bobbing
        OriginalZ = GetActorLocation().Z;

        // Set up the mesh based on the item
        UpdateMeshFromItem();

        // Bind overlap events
        InteractionSphere.OnComponentBeginOverlap.AddUFunction(this, n"OnInteractionBeginOverlap");
        InteractionSphere.OnComponentEndOverlap.AddUFunction(this, n"OnInteractionEndOverlap");

        FString ItemName = (ItemToPickup != nullptr) ? ItemToPickup.GetDisplayName() : "None";
        Log(f"PickupActor {GetName()} initialized with item: {ItemName}");
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        if (bIsCollected && !bIsReusable)
            return;

        TimeAccumulator += DeltaTime;

        FVector CurrentLocation = GetActorLocation();
        FRotator CurrentRotation = GetActorRotation();

        // Handle rotation
        if (bRotatePickup)
        {
            CurrentRotation.Yaw += RotationSpeed * DeltaTime;
            SetActorRotation(CurrentRotation);
        }

        // Handle bobbing
        if (bBobUpAndDown)
        {
            float BobOffset = Math::Sin(TimeAccumulator * BobSpeed) * BobHeight;
            CurrentLocation.Z = OriginalZ + BobOffset;
            SetActorLocation(CurrentLocation);
        }
    }

    void UpdateMeshFromItem()
    {
        if (ItemToPickup != nullptr && ItemToPickup.HasValidMesh())
        {
            Mesh.SetStaticMesh(ItemToPickup.ItemMesh);
            
            if (ItemToPickup.ItemMaterial != nullptr)
            {
                Mesh.SetMaterial(0, ItemToPickup.ItemMaterial);
            }

            // Apply any transform from the item data
            FTransform ItemTransform = ItemToPickup.GetHeldItemTransform();
            Mesh.SetRelativeTransform(ItemTransform);
        }
        else
        {
            Log(f"PickupActor {GetName()}: No valid mesh found for item");
        }
    }

    UFUNCTION()
    void OnInteractionBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult&in Hit)
    {
        // Check if the overlapping actor has an interaction capability
        UInteractionCapability InteractionCap = UInteractionCapability::Get(OtherActor);
        if (InteractionCap != nullptr)
        {
            InteractionCap.RegisterInteractable(this);
        }
    }

    UFUNCTION()
    void OnInteractionEndOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex)
    {
        // Remove this pickup from the interaction capability
        UInteractionCapability InteractionCap = UInteractionCapability::Get(OtherActor);
        if (InteractionCap != nullptr)
        {
            InteractionCap.UnregisterInteractable(this);
        }
    }

    // Called by interaction capability when player interacts
    UFUNCTION(BlueprintCallable, Category = "Pickup")
    bool TryPickup(AActor InteractingActor)
    {
        if (bIsCollected && !bIsReusable)
        {
            Log("Pickup already collected and not reusable");
            return false;
        }

        if (ItemToPickup == nullptr)
        {
            Log("No item to pickup");
            return false;
        }

        // Try to add to inventory
        UInventoryComponent Inventory = UInventoryComponent::Get(InteractingActor);
        if (Inventory == nullptr)
        {
            Log("Interacting actor has no inventory");
            return false;
        }

        bool bSuccess = Inventory.AddItemToFirstAvailableSlot(ItemToPickup);
        if (bSuccess)
        {
            Log(f"Successfully picked up {ItemToPickup.GetDisplayName()}");
            OnPickedUp(InteractingActor);
            return true;
        }
        else
        {
            Log("Inventory is full");
            return false;
        }
    }

    void OnPickedUp(AActor InteractingActor)
    {
        bIsCollected = true;

        if (!bIsReusable)
        {
            // Hide the pickup
            SetActorHiddenInGame(true);
            SetActorEnableCollision(false);
            
            // Optionally destroy after a delay
            SetLifeSpan(1.0f);
        }

        // Broadcast pickup event
        OnItemPickedUp(InteractingActor, ItemToPickup);
    }

    // Override this or bind to it for custom pickup behavior
    UFUNCTION(BlueprintCallable, Category = "Pickup")
    void OnItemPickedUp(AActor InteractingActor, UInventoryItemData PickedUpItem)
    {
        // Base implementation - override for custom behavior
    }

    // Utility functions
    UFUNCTION(BlueprintCallable, Category = "Pickup")
    FString GetInteractionText() const
    {
        if (ItemToPickup != nullptr)
        {
            return f"Press F to pick up {ItemToPickup.GetDisplayName()}";
        }
        return "Press F to interact";
    }

    UFUNCTION(BlueprintCallable, Category = "Pickup")
    bool CanBePickedUp() const
    {
        return ItemToPickup != nullptr && (!bIsCollected || bIsReusable);
    }

    UFUNCTION(BlueprintCallable, Category = "Pickup")
    void ResetPickup()
    {
        bIsCollected = false;
        SetActorHiddenInGame(false);
        SetActorEnableCollision(true);
        SetLifeSpan(0.0f); // Cancel destruction
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