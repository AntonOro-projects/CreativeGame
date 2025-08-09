// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseECSPawn.h"
#include "Engine/World.h"

ABaseECSPawn::ABaseECSPawn()
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

void ABaseECSPawn::BeginPlay()
{
	Super::BeginPlay();
	
	// Initialize capabilities through the manager
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}

void ABaseECSPawn::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	// Manual tick capabilities if enabled
	if (bManualCapabilityTicking && CapabilityManager)
	{
		CapabilityManager->ManualTick(DeltaTime);
	}
}

// Capability management - all methods delegate to CapabilityManager
UBaseCapability* ABaseECSPawn::AddCapability(TSubclassOf<UBaseCapability> CapabilityClass)
{
	return CapabilityManager ? CapabilityManager->AddCapability(CapabilityClass) : nullptr;
}

void ABaseECSPawn::AddCapabilityInstance(UBaseCapability* Capability)
{
	if (CapabilityManager)
	{
		CapabilityManager->AddCapabilityInstance(Capability);
	}
}

void ABaseECSPawn::RemoveCapability(UBaseCapability* Capability)
{
	if (CapabilityManager)
	{
		CapabilityManager->RemoveCapability(Capability);
	}
}

UBaseCapability* ABaseECSPawn::GetCapability(TSubclassOf<UBaseCapability> CapabilityClass) const
{
	return CapabilityManager ? CapabilityManager->GetCapability(CapabilityClass) : nullptr;
}

TArray<UBaseCapability*> ABaseECSPawn::GetCapabilities(TSubclassOf<UBaseCapability> CapabilityClass) const
{
	return CapabilityManager ? CapabilityManager->GetCapabilities(CapabilityClass) : TArray<UBaseCapability*>();
}

TArray<UBaseCapability*> ABaseECSPawn::GetAllCapabilities() const
{
	return CapabilityManager ? CapabilityManager->GetAllCapabilities() : TArray<UBaseCapability*>();
}

TArray<UBaseCapability*> ABaseECSPawn::GetActiveCapabilities() const
{
	return CapabilityManager ? CapabilityManager->GetActiveCapabilities() : TArray<UBaseCapability*>();
}

void ABaseECSPawn::RemoveComponent(UActorComponent* Component)
{
	if (CapabilityManager)
	{
		CapabilityManager->RemoveActorComponent(Component);
	}
}

void ABaseECSPawn::UpdateCapabilityStates()
{
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}