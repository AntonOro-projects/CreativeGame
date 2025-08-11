class ANormalPlayer : ABaseECSActor
{
    default bReplicates = true;
    default bReplicateMovement = true;

    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent Mesh;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // All we need to do is add the capability - it handles everything else!
        UCapabilityManagerComponent::GetOrCreate(this).AddCapability(UActorPickupCapability);
    }
};

class ANormalPlayerCharacter : ABaseECSCharacter
{
    default bReplicates = true;
    default bReplicateMovement = true;
    
    // Do NOT replace the Character's root (CapsuleComponent). Leave attach unspecified so it attaches to the inherited root.
    UPROPERTY(DefaultComponent)
    UStaticMeshComponent StaticMesh;

    UPROPERTY()
    UInputAction MoveAction; // Axis2D

    UPROPERTY()
    UInputAction JumpAction;

    UPROPERTY()
    UInputAction MoveCamera;

    UPROPERTY()
    UInputMappingContext Context;

    // Inventory input actions
    UPROPERTY()
    UInputAction SelectSlot1Action;

    UPROPERTY()
    UInputAction SelectSlot2Action;

    UPROPERTY()
    UInputAction SelectSlot3Action;

    UPROPERTY()
    UInputAction SelectSlot4Action;

    UPROPERTY()
    UInputAction SelectSlot5Action;

    UPROPERTY()
    UInputMappingContext InventoryInputContext;

    // Interaction input
    UPROPERTY()
    UInputAction InteractAction;

    UPROPERTY()
    UInputMappingContext InteractionInputContext;

    // HUD setup
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "UI")
    TSubclassOf<UPlayerHUD> PlayerHUDClass;

    UCapabilityManagerComponent CachedCapabilityManager;

    UPROPERTY()
    UPlayerMovementComponent PlayerMovement;

    UPROPERTY()
    UInventoryComponent InventoryComponent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);

        //CachedCapabilityManager.AddCapability(UMovementCapability);

        PlayerMovement = UPlayerMovementComponent::Create(this);
        PlayerMovement.Setup();

        // Create inventory component
        InventoryComponent = UInventoryComponent::Create(this);

        // Add inventory capabilities - they will get input actions directly from this character
        CachedCapabilityManager.AddCapability(UInventoryInputCapability);

        // Add inventory visuals capability
        CachedCapabilityManager.AddCapability(UInventoryVisualsCapability);

        // Add interaction capability
        CachedCapabilityManager.AddCapability(UInteractionCapability);

        // Add HUD capability
        CachedCapabilityManager.AddCapability(UPlayerHUDCapability);

        // Test adding items to inventory
        //TestAddItemsToInventory();

        Log("Player character initialized with actor-based inventory system");

	}
};