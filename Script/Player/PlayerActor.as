class ANormalPlayer : ABaseECSActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent Mesh;

};

class ANormalPlayerCharacter : ABaseECSCharacter
{
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

    UCapabilityManagerComponent CachedCapabilityManager;

    UPROPERTY()
    UPlayerMovementComponent PlayerMovement;

    UPROPERTY()
    UInventoryComponent InventoryComponent;

    // Reference to your editor-created sword asset
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Test Items")
    UInventoryItemData EditorSwordAsset; // Assign your DA_Sword here in the editor

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

        // Add inventory test capability for development
        CachedCapabilityManager.AddCapability(UInventoryTestCapability);

        // Add interaction capability
        CachedCapabilityManager.AddCapability(UInteractionCapability);

        // Test adding items to inventory
        //TestAddItemsToInventory();

        Log("Player character initialized with inventory system");

	}

    void TestAddItemsToInventory()
    {
        if (InventoryComponent == nullptr)
        {
            Log("InventoryComponent is null, cannot add items");
            return;
        }

        // Method 2: Add the editor-created asset (if assigned)
        if (EditorSwordAsset != nullptr)
        {
            bool bSuccess2 = InventoryComponent.AddItemToFirstAvailableSlot(EditorSwordAsset);
            if (bSuccess2)
            {
                Log("Successfully added EditorSwordAsset (DA_Sword) to inventory");
            }
            else
            {
                Log("Failed to add EditorSwordAsset to inventory");
            }
        }
        else
        {
            Log("EditorSwordAsset is null - assign your DA_Sword asset in the editor");
        }

        // Set the first item as selected
        InventoryComponent.SetSelectedSlot(0);
        Log("Set inventory slot 1 as selected");
    }
};