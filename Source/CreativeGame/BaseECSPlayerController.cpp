// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseECSPlayerController.h"
#include "Components/InputComponent.h"
#include "Engine/World.h"

ABaseECSPlayerController::ABaseECSPlayerController()
{
	PrimaryActorTick.bCanEverTick = true;
	
	// Create the capability manager component
	CapabilityManager = CreateDefaultSubobject<UCapabilityManagerComponent>(TEXT("CapabilityManager"));
	
	// Disable auto-ticking on the component since we'll manually tick it
	if (CapabilityManager)
	{
		CapabilityManager->SetComponentTickEnabled(false);
	}
}

void ABaseECSPlayerController::PostInitializeComponents()
{
	Super::PostInitializeComponents();
	
	// Initialize capabilities early
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}

void ABaseECSPlayerController::BeginPlay()
{
	Super::BeginPlay();
	
	// Additional capability initialization if needed
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}

void ABaseECSPlayerController::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	// Manual tick capabilities if enabled
	if (bManualCapabilityTicking && CapabilityManager)
	{
		CapabilityManager->ManualTick(DeltaTime);
	}
}

void ABaseECSPlayerController::SetupInputComponent()
{
	Super::SetupInputComponent();

	// Add player controller-specific input bindings here
	// Individual capabilities can also bind to input if needed
}