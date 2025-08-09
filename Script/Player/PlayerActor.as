class ANormalPlayer : ABaseECSActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent Mesh;

      
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        AddCapability(UMovementCapability);
    };

};

class ANormalPlayerCharacter : ACharacter
{
    
}

class UMovementCapability : UBaseCapability
{
    UInputComponent InputComponent;
    bool bIsSprinting = false;
    bool bWarnedNoPawn = false;
    bool bWarnedNoCharacter = false;
    float WalkSpeed = 600.0f;
    float SprintSpeed = 900.0f;

    UFUNCTION(BlueprintOverride)
    bool ShouldBeActive() const
    {
        return true;
    }

    
    UFUNCTION(BlueprintOverride)
    void OnCapabilityActivated()
    {
        InputComponent = UInputComponent::GetOrCreate(Owner);

        // Set up any action mappings we want to use while possessed
        //  The action names used can be configured within the project's input settings or DefaultInput.ini
        //  Note that these bindings consume the input and override any InputAction nodes in the blueprint
        InputComponent.BindAction(n"Jump", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnJumpPressed"));
        InputComponent.BindAction(n"Jump", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"OnJumpReleased"));

        // Set up some axis bindings to receive the values of control axes
        //  Note that these bindings consume the input and override any InputAxis nodes in the blueprint
        InputComponent.BindAxis(n"MoveForward", FInputAxisHandlerDynamicSignature(this, n"OnMoveForwardAxisChanged"));
        InputComponent.BindAxis(n"MoveRight", FInputAxisHandlerDynamicSignature(this, n"OnMoveRightAxisChanged"));

        // You can also bind to a specific hardcoded key, bypassing action mappings
        //   These bindings do not consume input, and work alongside action mappings.
        InputComponent.BindKey(EKeys::LeftShift, EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnShiftPressed"));

        // You can bind to AnyKey to receive all key events and do your own manual mapping if you wish
        //   These bindings do not consume input, and work alongside action mappings.
        InputComponent.BindKey(EKeys::AnyKey, EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnKeyPressed"));

        // Ensure default walk speed if we have a character movement
        ACharacter CharOwner = Cast<ACharacter>(Owner);
        if (CharOwner != nullptr && CharOwner.CharacterMovement != nullptr)
        {
            CharOwner.CharacterMovement.MaxWalkSpeed = WalkSpeed;
        }
    }

    UFUNCTION()
    private void OnJumpPressed(FKey Key)
    {
        ACharacter CharOwner = Cast<ACharacter>(Owner);
        if (CharOwner != nullptr)
        {
            CharOwner.Jump();
            return;
        }

        if (!bWarnedNoCharacter)
        {
            Print("Jump pressed, but Owner is not a Character.", Duration=2.0);
            bWarnedNoCharacter = true;
        }
    }

    UFUNCTION()
    private void OnJumpReleased(FKey Key)
    {
        ACharacter CharOwner = Cast<ACharacter>(Owner);
        if (CharOwner != nullptr)
        {
            CharOwner.StopJumping();
            return;
        }
    }

    UFUNCTION()
    private void OnMoveForwardAxisChanged(float32 AxisValue)
    {
        if (Math::Abs(AxisValue) < 0.01f)
            return;

        APawn PawnOwner = Cast<APawn>(Owner);
        if (PawnOwner != nullptr)
        {
            // Use control rotation to move relative to camera facing
            FVector Dir = PawnOwner.ControlRotation.ForwardVector;
            PawnOwner.AddMovementInput(Dir, AxisValue);
            return;
        }

        if (!bWarnedNoPawn)
        {
            Print("Owner is not a Pawn; AddMovementInput not available.", Duration=2.0);
            bWarnedNoPawn = true;
        }
    }

    UFUNCTION()
    private void OnMoveRightAxisChanged(float32 AxisValue)
    {
        if (Math::Abs(AxisValue) < 0.01f)
            return;

        APawn PawnOwner = Cast<APawn>(Owner);
        if (PawnOwner != nullptr)
        {
            FVector Dir = PawnOwner.ControlRotation.RightVector;
            PawnOwner.AddMovementInput(Dir, AxisValue);
            return;
        }
    }

    UFUNCTION()
    private void OnShiftPressed(FKey Key)
    {
        bIsSprinting = !bIsSprinting;

        ACharacter CharOwner = Cast<ACharacter>(Owner);
        if (CharOwner != nullptr && CharOwner.CharacterMovement != nullptr)
        {
            CharOwner.CharacterMovement.MaxWalkSpeed = bIsSprinting ? SprintSpeed : WalkSpeed;
            return;
        }
    }

    UFUNCTION()
    private void OnKeyPressed(FKey Key)
    {
    // Optional: quick debug print for input visibility
    // Print("Key Pressed: " + Key.KeyName, Duration=1.0);
    }
};

class UMyComponent : UActorComponent
{
    
};