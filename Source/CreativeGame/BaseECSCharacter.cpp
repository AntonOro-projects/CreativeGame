// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseECSCharacter.h"
#include "Components/InputComponent.h"
#include "Engine/World.h"

ABaseECSCharacter::ABaseECSCharacter()
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

void ABaseECSCharacter::BeginPlay()
{
	Super::BeginPlay();
	
	// Initialize capabilities through the manager
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}

void ABaseECSCharacter::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	// Manual tick capabilities if enabled
	if (bManualCapabilityTicking && CapabilityManager)
	{
		CapabilityManager->ManualTick(DeltaTime);
	}
}

void ABaseECSCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	// Add character-specific input bindings here
	// Individual capabilities can also bind to input if needed
}