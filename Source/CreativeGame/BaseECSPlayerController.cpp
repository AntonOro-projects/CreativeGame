// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseECSPlayerController.h"
#include "Components/InputComponent.h"
#include "Engine/World.h"

ABaseECSPlayerController::ABaseECSPlayerController()
{
	PrimaryActorTick.bCanEverTick = true;
	
	// Initialize ECS component
	INITIALIZE_ECS_COMPONENT(TEXT("CapabilityManager"));
}

void ABaseECSPlayerController::PostInitializeComponents()
{
	Super::PostInitializeComponents();
	
	// Initialize ECS capabilities early
	ECS_BEGIN_PLAY();
}

void ABaseECSPlayerController::BeginPlay()
{
	Super::BeginPlay();
	
	// Additional ECS initialization if needed
	ECS_BEGIN_PLAY();
}

void ABaseECSPlayerController::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	// Tick ECS capabilities
	ECS_TICK(DeltaTime);
}

void ABaseECSPlayerController::SetupInputComponent()
{
	Super::SetupInputComponent();

	// Add player controller-specific input bindings here
	// Individual capabilities can also bind to input if needed
}

// Implement all ECS capability management functions using macro
IMPLEMENT_ECS_CAPABILITY_FUNCTIONS(ABaseECSPlayerController)