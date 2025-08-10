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

    UCapabilityManagerComponent CachedCapabilityManager;

    UPROPERTY()
    UPlayerMovementComponent PlayerMovement;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);

        //CachedCapabilityManager.AddCapability(UMovementCapability);

        PlayerMovement = UPlayerMovementComponent::Create(this);
        PlayerMovement.Setup();

        CachedCapabilityManager.AddCapability(UInventoryCapability);
	}
};