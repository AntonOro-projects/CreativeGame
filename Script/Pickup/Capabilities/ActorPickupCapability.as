/**
 * Enhanced pickup capability that adds the entire actor to inventory instead of just data
 */
class UActorPickupCapability : UBaseCapability
{
    // Whether this pickup has been collected
    UPROPERTY(BlueprintReadOnly, Category = "Pickup")
    bool bIsCollected = false;

    // Whether this pickup can be picked up multiple times
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Pickup")
    bool bIsReusable = false;

    // Interaction distance
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Pickup")
    float InteractionRadius = 150.0f;

    // Visual feedback settings
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    bool bRotatePickup = true;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    float RotationSpeed = 90.0f; // degrees per second

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    bool bBobUpAndDown = true;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    float BobHeight = 10.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Visual")
    float BobSpeed = 2.0f;

    // Internal state
    FVector OriginalLocation;
    float TimeAccumulator = 0.0f;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive()
    {
        return !bIsCollected || bIsReusable;
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityActivated()
    {
        AActor OwnerActor = GetOwner();
        if (OwnerActor != nullptr)
        {
            OriginalLocation = OwnerActor.GetActorLocation();
            
            // Add InteractionCapability as a dependency so this actor can be interacted with
            UCapabilityManagerComponent CapManager = UCapabilityManagerComponent::Get(OwnerActor);
            if (CapManager != nullptr)
            {
                CapManager.AddCapability(UInteractionCapability);
                Log(f"ActorPickupCapability added InteractionCapability dependency to {OwnerActor.GetName()}");
            }
        }
    }

    // Called by InteractionCapability when interaction starts
    UFUNCTION(BlueprintCallable, Category = "Interaction Events")
    void OnInteractionStarted(AActor InteractingActor, AActor TargetActor)
    {
        Log(f"Pickup interaction started by {InteractingActor.GetName()} on {TargetActor.GetName()}");
        
        // Try to perform the pickup
        bool bSuccess = TryPickup(InteractingActor);
        if (bSuccess)
        {
            Log(f"Pickup successful for {TargetActor.GetName()}");
            
            // Notify the interaction capability that we handled this successfully
            UInteractionCapability InteractionCap = UInteractionCapability::Get(InteractingActor);
            if (InteractionCap != nullptr)
            {
                InteractionCap.OnInteractionHandled(InteractingActor, TargetActor, true);
            }
        }
        else
        {
            Log(f"Pickup failed for {TargetActor.GetName()}");
        }
    }

    UFUNCTION(BlueprintOverride)
    void OnCapabilityDeactivated()
    {
        // Unregister from interaction system
        UnregisterFromInteraction();
    }

    UFUNCTION(BlueprintOverride)
    void TickCapability(float DeltaTime)
    {
        UpdateVisualEffects(DeltaTime);
    }

    void UpdateVisualEffects(float DeltaTime)
    {
        AActor OwnerActor = GetOwner();
        if (OwnerActor == nullptr)
            return;

        TimeAccumulator += DeltaTime;

        FVector NewLocation = OriginalLocation;
        FRotator NewRotation = OwnerActor.GetActorRotation();

        // Apply bobbing
        if (bBobUpAndDown)
        {
            float BobOffset = Math::Sin(TimeAccumulator * BobSpeed) * BobHeight;
            NewLocation.Z += BobOffset;
        }

        // Apply rotation
        if (bRotatePickup)
        {
            NewRotation.Yaw += RotationSpeed * DeltaTime;
        }

        OwnerActor.SetActorLocation(NewLocation);
        OwnerActor.SetActorRotation(NewRotation);
    }

    void RegisterWithActor(AActor Actor)
    {
        UInteractionCapability InteractionCap = UInteractionCapability::Get(Actor);
        if (InteractionCap != nullptr)
        {
            InteractionCap.RegisterInteractable(GetOwner());
        }
    }

    void UnregisterFromInteraction()
    {
        // For now, we'll rely on the existing interaction system
        // TODO: Implement proper cleanup when needed
        
        AActor OwnerActor = GetOwner();
        if (OwnerActor != nullptr)
        {
            UInteractionCapability InteractionCap = UInteractionCapability::Get(OwnerActor);
            if (InteractionCap != nullptr)
            {
                InteractionCap.UnregisterInteractable(OwnerActor);
            }
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

        // Try to add to actor-based inventory
        UInventoryComponent ActorInventory = UInventoryComponent::Get(InteractingActor);
        if (ActorInventory != nullptr)
        {
            bool bSuccess = ActorInventory.AddItemToFirstAvailableSlot(GetOwner());
            if (bSuccess)
            {
                Log("Successfully picked up " + GetOwner().GetName() + " (actor-based)");
                OnPickedUp(InteractingActor);
                return true;
            }
            else
            {
                Log("Actor inventory is full");
                return false;
            }
        }

        // Fallback to data-based inventory (for compatibility)
        UInventoryComponent DataInventory = UInventoryComponent::Get(InteractingActor);
        if (DataInventory != nullptr)
        {
            // For data inventory, we need to create a data asset or have one configured
            Log("Data-based inventory not supported for actor pickups");
            return false;
        }

        Log("Interacting actor has no compatible inventory");
        return false;
    }

    void OnPickedUp(AActor InteractingActor)
    {
        bIsCollected = true;

        if (!bIsReusable)
        {
            // The actor will be hidden and managed by the inventory system
            // No need to destroy it since it's now part of the inventory
        }

        // Broadcast pickup event
        OnItemPickedUp(InteractingActor);
    }

    // Override this or bind to it for custom pickup behavior
    UFUNCTION(BlueprintCallable, Category = "Pickup")
    void OnItemPickedUp(AActor InteractingActor)
    {
        // Override in derived classes or bind to this event
    }
};
