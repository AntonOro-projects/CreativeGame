class UPlayerMovementComponent : UEnhancedInputComponent
{
    UPROPERTY(Category = "Input Actions")
    UInputAction MoveAction; // Axis2D

    UPROPERTY(Category = "Input Actions")
    UInputAction JumpAction;

    UPROPERTY(Category = "Input Actions")
    UInputAction MoveCamera;

    UPROPERTY(Category = "Input Actions")
    UInputMappingContext Context;

    ANormalPlayerCharacter PlayerCharacter;

    bool bIsSprinting = false;
    bool bWarnedNoPawn = false;
    bool bWarnedNoCharacter = false;
    float WalkSpeed = 600.0f;
    float SprintSpeed = 900.0f;
    float LookSensitivityYaw = 1.0f;   // turn speed scale
    float LookSensitivityPitch = 1.0f; // look up/down speed scale
    bool bInvertY = false;             // typical default: not inverted
    float MinPitch = -80.0f;           // clamp to avoid flipping
    float MaxPitch = 80.0f;
    
    UFUNCTION()
    void Setup()
    {
        PlayerCharacter = Cast<ANormalPlayerCharacter>(GetOwner());
        if (PlayerCharacter != nullptr)
        {
            MoveAction = PlayerCharacter.MoveAction;
            JumpAction = PlayerCharacter.JumpAction;
            MoveCamera = PlayerCharacter.MoveCamera;
            Context = PlayerCharacter.Context;
        }
        APlayerController PlayerController = PlayerCharacter != nullptr ? Cast<APlayerController>(PlayerCharacter.GetController()) : nullptr;
        if (PlayerController != nullptr)
        {
            // Ensure this input component is in the stack so bindings receive events
            PlayerController.PushInputComponent(this);
            if (Context != nullptr)
            {
                UEnhancedInputLocalPlayerSubsystem EnhancedInputSubsystem = UEnhancedInputLocalPlayerSubsystem::Get(PlayerController);
                if (EnhancedInputSubsystem != nullptr)
                {
                    EnhancedInputSubsystem.AddMappingContext(Context, 0, FModifyContextOptions());       
                }
            }
        }
        
        // Bind movement (2D axis). Triggered fires every frame while held.
        if (MoveAction != nullptr)
            BindAction(MoveAction, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"OnMove"));

        // Bind camera look (2D axis)
        if (MoveCamera != nullptr)
            BindAction(MoveCamera, ETriggerEvent::Triggered, FEnhancedInputActionHandlerDynamicSignature(this, n"OnLook"));

        // Bind jump actions
        if (JumpAction != nullptr)
        {
            BindAction(JumpAction, ETriggerEvent::Started, FEnhancedInputActionHandlerDynamicSignature(this, n"OnJumpStarted"));
            BindAction(JumpAction, ETriggerEvent::Completed, FEnhancedInputActionHandlerDynamicSignature(this, n"OnJumpCompleted"));
        }

        // Ensure default walk speed if we have a character movement
        ACharacter CharOwner = Cast<ACharacter>(GetOwner());
        if (CharOwner != nullptr && CharOwner.CharacterMovement != nullptr)
        {
            CharOwner.CharacterMovement.MaxWalkSpeed = WalkSpeed;
        }
    }

    UFUNCTION()
    private void OnMove(FInputActionValue ActionValue, float32 ElapsedTime,
                              float32 TriggeredTime, const UInputAction SourceAction)
    {
        if (PlayerCharacter == nullptr)
            return;
        FVector2D Axis = ActionValue.GetAxis2D();
        // Use yaw-only control rotation so movement is camera-relative without pitch affecting speed
        FRotator YawRot = FRotator(0.0f, PlayerCharacter.ControlRotation.Yaw, 0.0f);
        FVector Forward = YawRot.ForwardVector;
        FVector Right = YawRot.RightVector;
        if (Axis.Y != 0.0f)
            PlayerCharacter.AddMovementInput(Forward, Axis.Y);
        if (Axis.X != 0.0f)
            PlayerCharacter.AddMovementInput(Right, Axis.X);
    }

    UFUNCTION()
    private void OnLook(FInputActionValue ActionValue, float32 ElapsedTime,
                        float32 TriggeredTime, const UInputAction SourceAction)
    {
        if (PlayerCharacter == nullptr)
            return;

        FVector2D LookAxis = ActionValue.GetAxis2D();

        // Scale by sensitivity; for mouse delta mappings, the context usually provides per-frame delta already
        float YawDelta = LookAxis.X * LookSensitivityYaw;
        float PitchDelta = (bInvertY ? -LookAxis.Y : LookAxis.Y) * LookSensitivityPitch;

        // Update controller rotation directly to avoid wrap-around and snapping
        AController C = PlayerCharacter.Controller;
        if (C != nullptr)
        {
            FRotator CtrlRot = PlayerCharacter.ControlRotation;
            CtrlRot.Yaw += YawDelta;
            CtrlRot.Pitch = Math::Clamp(CtrlRot.Pitch + PitchDelta, MinPitch, MaxPitch);
            C.SetControlRotation(CtrlRot);
        }
    }

    UFUNCTION()
    private void OnJumpStarted(FInputActionValue ActionValue, float32 ElapsedTime,
                              float32 TriggeredTime, const UInputAction SourceAction)
    {
        if (PlayerCharacter == nullptr)
            return;
        PlayerCharacter.Jump();
    }

    UFUNCTION()
    private void OnJumpCompleted(FInputActionValue ActionValue, float32 ElapsedTime,
                              float32 TriggeredTime, const UInputAction SourceAction)
    {
        if (PlayerCharacter == nullptr)
            return;
        PlayerCharacter.StopJumping();
    }

};