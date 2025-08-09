class ANormalPlayer : ABaseECSActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent Mesh;

      
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        //AddCapability(UMovementCapability);
    };

};

class ANormalPlayerCharacter : ABaseECSCharacter
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent StaticMesh;

    UPROPERTY()
    UInputAction Action;

    UPROPERTY()
    UInputMappingContext Context;

    UCapabilityManagerComponent CachedCapabilityManager;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
        CachedCapabilityManager = UCapabilityManagerComponent::GetOrCreate(this);

        //CachedCapabilityManager.AddCapability(UMovementCapability);

       UPlayerMovementComponent PlayerMovementComponent = UPlayerMovementComponent::Create(this);
       PlayerMovementComponent.Setup();
	}
};

class UPlayerMovementComponent : UEnhancedInputComponent
{
    UPROPERTY(Category = "Input Actions")
    UInputAction Action;

    UPROPERTY(Category = "Input Actions")
    UInputMappingContext Context;

    ANormalPlayerCharacter PlayerCharacter;

    bool bIsSprinting = false;
    bool bWarnedNoPawn = false;
    bool bWarnedNoCharacter = false;
    float WalkSpeed = 600.0f;
    float SprintSpeed = 900.0f;
    
    UFUNCTION()
    void Setup()
    {
        PlayerCharacter = Cast<ANormalPlayerCharacter>(Owner);
        if (PlayerCharacter != nullptr)
        {
            Action = PlayerCharacter.Action;
            Context = PlayerCharacter.Context;
        }
        APlayerController PlayerController = Cast<APlayerController>(PlayerCharacter.GetController());
        UEnhancedInputLocalPlayerSubsystem EnhancedInputSubsystem = UEnhancedInputLocalPlayerSubsystem::Get(PlayerController);
        EnhancedInputSubsystem.AddMappingContext(Context, 0, FModifyContextOptions());        
        
        BindAction(Action, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"OnKeyPressed"));

        // Ensure default walk speed if we have a character movement
        ACharacter CharOwner = Cast<ACharacter>(Owner);
        if (CharOwner != nullptr && CharOwner.CharacterMovement != nullptr)
        {
            CharOwner.CharacterMovement.MaxWalkSpeed = WalkSpeed;
        }
    }

    UFUNCTION()
    private void OnKeyPressed(FInputActionValue ActionValue, float32 ElapsedTime,
                              float32 TriggeredTime, const UInputAction SourceAction)
    {
        FVector Dir = PlayerCharacter.ControlRotation.ForwardVector;
        PlayerCharacter.AddMovementInput(Dir);
        Log(f"pos: {PlayerCharacter.GetActorLocation()}");
    }
};

class UMyComponent : UActorComponent
{
    
};