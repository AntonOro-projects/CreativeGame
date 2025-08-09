// Fill out your copyright notice in the Description page of Project Settings.

#include "Components/CapabilityManagerComponent.h"
#include "Engine/World.h"

UCapabilityManagerComponent::UCapabilityManagerComponent()
{
	PrimaryComponentTick.bCanEverTick = true;
	PrimaryComponentTick.bStartWithTickEnabled = true;
}

void UCapabilityManagerComponent::BeginPlay()
{
	Super::BeginPlay();
	
	// Initialize any capabilities that should start active
	UpdateCapabilityStates();
	
	// Set ticking based on configuration
	SetComponentTickEnabled(bAutoTick);
}

void UCapabilityManagerComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
	
	ManualTick(DeltaTime);
}

void UCapabilityManagerComponent::ManualTick(float DeltaTime)
{
	const float CurrentTime = GetWorld()->GetTimeSeconds();
	
	// Update capability activation states periodically (performance optimization)
	if (CurrentTime - LastCapabilityUpdateTime >= CapabilityUpdateFrequency)
	{
		UpdateCapabilityStates();
		LastCapabilityUpdateTime = CurrentTime;
	}

	// Tick only active capabilities
	for (UBaseCapability* Capability : ActiveCapabilities)
	{
		if (IsValid(Capability))
		{
			Capability->TickCapability(DeltaTime);
		}
	}
}

UBaseCapability* UCapabilityManagerComponent::AddCapability(TSubclassOf<UBaseCapability> CapabilityClass)
{
	if (!CapabilityClass)
	{
		return nullptr;
	}

	// Create new capability component
	UBaseCapability* NewCapability = NewObject<UBaseCapability>(GetOwner(), CapabilityClass);
	if (NewCapability)
	{
		AddCapabilityInstance(NewCapability);
	}

	return NewCapability;
}

void UCapabilityManagerComponent::AddCapabilityInstance(UBaseCapability* Capability)
{
	if (!IsValid(Capability) || Capabilities.Contains(Capability))
	{
		return;
	}

	// Ensure the capability is owned by this actor
	if (Capability->GetOwner() != GetOwner())
	{
		Capability->Rename(nullptr, GetOwner());
	}

	// Register the capability if not already registered
	if (!Capability->IsRegistered())
	{
		Capability->RegisterComponent();
	}

	Capabilities.Add(Capability);
	
	// Sort capabilities by priority (higher priority first)
	Capabilities.Sort([](const UBaseCapability& A, const UBaseCapability& B) {
		return A.GetPriority() > B.GetPriority();
	});

	// Check if it should be activated immediately
	UpdateCapabilityActivation(Capability);
}

void UCapabilityManagerComponent::RemoveCapability(UBaseCapability* Capability)
{
	if (!IsValid(Capability))
	{
		return;
	}

	// Deactivate if currently active
	if (ActiveCapabilities.Contains(Capability))
	{
		DeactivateCapability(Capability);
	}

	Capabilities.Remove(Capability);
	Capability->DestroyComponent();
}

void UCapabilityManagerComponent::RemoveActorComponent(UActorComponent* Component)
{
	if (!IsValid(Component))
	{
		return;
	}

	if (UBaseCapability* Capability = Cast<UBaseCapability>(Component))
	{
		RemoveCapability(Capability);
	}
	else
	{
		Component->DestroyComponent();
	}
}

UBaseCapability* UCapabilityManagerComponent::GetCapability(TSubclassOf<UBaseCapability> CapabilityClass) const
{
	if (!CapabilityClass)
	{
		return nullptr;
	}

	for (UBaseCapability* Capability : Capabilities)
	{
		if (IsValid(Capability) && Capability->IsA(CapabilityClass))
		{
			return Capability;
		}
	}
	return nullptr;
}

TArray<UBaseCapability*> UCapabilityManagerComponent::GetCapabilities(TSubclassOf<UBaseCapability> CapabilityClass) const
{
	TArray<UBaseCapability*> FoundCapabilities;
	
	if (!CapabilityClass)
	{
		return FoundCapabilities;
	}

	for (UBaseCapability* Capability : Capabilities)
	{
		if (IsValid(Capability) && Capability->IsA(CapabilityClass))
		{
			FoundCapabilities.Add(Capability);
		}
	}
	return FoundCapabilities;
}

void UCapabilityManagerComponent::UpdateCapabilityStates()
{
	// Create a copy to avoid modification during iteration
	TArray<UBaseCapability*> CapabilitiesToCheck = Capabilities;

	for (UBaseCapability* Capability : CapabilitiesToCheck)
	{
		if (IsValid(Capability))
		{
			UpdateCapabilityActivation(Capability);
		}
	}
}

void UCapabilityManagerComponent::UpdateCapabilityActivation(UBaseCapability* Capability)
{
	if (!IsValid(Capability))
	{
		return;
	}

	const bool bIsCurrentlyActive = Capability->IsActive();
	const bool bShouldBeActive = Capability->ShouldBeActive();

	if (bIsCurrentlyActive)
	{
		// Check if it should deactivate
		if (!bShouldBeActive || Capability->ShouldDeactivate())
		{
			DeactivateCapability(Capability);
		}
	}
	else
	{
		// Check if it should activate
		if (bShouldBeActive && Capability->ShouldActivate())
		{
			ActivateCapability(Capability);
		}
	}
}

void UCapabilityManagerComponent::ActivateCapability(UBaseCapability* Capability)
{
	if (!IsValid(Capability) || Capability->IsActive())
	{
		return;
	}

	// Use built-in activation system
	Capability->SetActive(true);
	
	// Add to active list for efficient ticking
	if (!ActiveCapabilities.Contains(Capability))
	{
		ActiveCapabilities.Add(Capability);
	}
}

void UCapabilityManagerComponent::DeactivateCapability(UBaseCapability* Capability)
{
	if (!IsValid(Capability))
	{
		return;
	}

	// Use built-in deactivation system
	Capability->SetActive(false);
	
	// Remove from active list
	ActiveCapabilities.Remove(Capability);
}