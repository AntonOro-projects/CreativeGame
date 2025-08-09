// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseECSCharacter.h"
#include "Components/InputComponent.h"
#include "Engine/World.h"

ABaseECSCharacter::ABaseECSCharacter()
{
	PrimaryActorTick.bCanEverTick = true;
	
	// Initialize ECS component
	INITIALIZE_ECS_COMPONENT(TEXT("CapabilityManager"));
}

void ABaseECSCharacter::BeginPlay()
{
	Super::BeginPlay();
	
	// Initialize ECS capabilities
	ECS_BEGIN_PLAY();
}

void ABaseECSCharacter::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	// Tick ECS capabilities
	ECS_TICK(DeltaTime);
}

void ABaseECSCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	// Add character-specific input bindings here
	// Individual capabilities can also bind to input if needed
}

// Implement all ECS capability management functions using macro
IMPLEMENT_ECS_CAPABILITY_FUNCTIONS(ABaseECSCharacter)