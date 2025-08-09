// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseClass.h"
#include "Engine/World.h"

ABaseECSActor::ABaseECSActor()
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

void ABaseECSActor::BeginPlay()
{
	Super::BeginPlay();
	
	// Initialize capabilities through the manager
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}

void ABaseECSActor::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	// Manual tick capabilities if enabled
	if (bManualCapabilityTicking && CapabilityManager)
	{
		CapabilityManager->ManualTick(DeltaTime);
	}
}

// Capability management - all methods delegate to CapabilityManager
UBaseCapability* ABaseECSActor::AddCapability(TSubclassOf<UBaseCapability> CapabilityClass)
{
	return CapabilityManager ? CapabilityManager->AddCapability(CapabilityClass) : nullptr;
}

void ABaseECSActor::AddCapabilityInstance(UBaseCapability* Capability)
{
	if (CapabilityManager)
	{
		CapabilityManager->AddCapabilityInstance(Capability);
	}
}

void ABaseECSActor::RemoveCapability(UBaseCapability* Capability)
{
	if (CapabilityManager)
	{
		CapabilityManager->RemoveCapability(Capability);
	}
}

UBaseCapability* ABaseECSActor::GetCapability(TSubclassOf<UBaseCapability> CapabilityClass) const
{
	return CapabilityManager ? CapabilityManager->GetCapability(CapabilityClass) : nullptr;
}

TArray<UBaseCapability*> ABaseECSActor::GetCapabilities(TSubclassOf<UBaseCapability> CapabilityClass) const
{
	return CapabilityManager ? CapabilityManager->GetCapabilities(CapabilityClass) : TArray<UBaseCapability*>();
}

TArray<UBaseCapability*> ABaseECSActor::GetAllCapabilities() const
{
	return CapabilityManager ? CapabilityManager->GetAllCapabilities() : TArray<UBaseCapability*>();
}

TArray<UBaseCapability*> ABaseECSActor::GetActiveCapabilities() const
{
	return CapabilityManager ? CapabilityManager->GetActiveCapabilities() : TArray<UBaseCapability*>();
}

void ABaseECSActor::RemoveComponent(UActorComponent* Component)
{
	if (CapabilityManager)
	{
		CapabilityManager->RemoveActorComponent(Component);
	}
}

void ABaseECSActor::UpdateCapabilityStates()
{
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}