// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Components/CapabilityManagerComponent.h"

/**
 * Macros to reduce boilerplate code for ECS implementation across different Actor types.
 * These macros generate the standard capability management delegation code.
 */

// Declare ECS capability management functions in header
#define DECLARE_ECS_CAPABILITY_FUNCTIONS() \
	UFUNCTION(BlueprintCallable, Category = "Capabilities") \
	UBaseCapability* AddCapability(TSubclassOf<UBaseCapability> CapabilityClass); \
	\
	UFUNCTION(BlueprintCallable, Category = "Capabilities") \
	void AddCapabilityInstance(UBaseCapability* Capability); \
	\
	UFUNCTION(BlueprintCallable, Category = "Capabilities") \
	void RemoveCapability(UBaseCapability* Capability); \
	\
	UFUNCTION(BlueprintCallable, Category = "Capabilities") \
	UBaseCapability* GetCapability(TSubclassOf<UBaseCapability> CapabilityClass) const; \
	\
	UFUNCTION(BlueprintCallable, Category = "Capabilities") \
	TArray<UBaseCapability*> GetCapabilities(TSubclassOf<UBaseCapability> CapabilityClass) const; \
	\
	UFUNCTION(BlueprintCallable, Category = "Capabilities") \
	TArray<UBaseCapability*> GetAllCapabilities() const; \
	\
	UFUNCTION(BlueprintCallable, Category = "Capabilities") \
	TArray<UBaseCapability*> GetActiveCapabilities() const; \
	\
	UFUNCTION(BlueprintCallable, Category = "Components") \
	void RemoveComponent(UActorComponent* Component); \
	\
	UFUNCTION(BlueprintCallable, Category = "Capabilities") \
	void UpdateCapabilityStates();

// Implement ECS capability management functions in source file
#define IMPLEMENT_ECS_CAPABILITY_FUNCTIONS(ClassName) \
	UBaseCapability* ClassName::AddCapability(TSubclassOf<UBaseCapability> CapabilityClass) \
	{ \
		return CapabilityManager ? CapabilityManager->AddCapability(CapabilityClass) : nullptr; \
	} \
	\
	void ClassName::AddCapabilityInstance(UBaseCapability* Capability) \
	{ \
		if (CapabilityManager) \
		{ \
			CapabilityManager->AddCapabilityInstance(Capability); \
		} \
	} \
	\
	void ClassName::RemoveCapability(UBaseCapability* Capability) \
	{ \
		if (CapabilityManager) \
		{ \
			CapabilityManager->RemoveCapability(Capability); \
		} \
	} \
	\
	UBaseCapability* ClassName::GetCapability(TSubclassOf<UBaseCapability> CapabilityClass) const \
	{ \
		return CapabilityManager ? CapabilityManager->GetCapability(CapabilityClass) : nullptr; \
	} \
	\
	TArray<UBaseCapability*> ClassName::GetCapabilities(TSubclassOf<UBaseCapability> CapabilityClass) const \
	{ \
		return CapabilityManager ? CapabilityManager->GetCapabilities(CapabilityClass) : TArray<UBaseCapability*>(); \
	} \
	\
	TArray<UBaseCapability*> ClassName::GetAllCapabilities() const \
	{ \
		return CapabilityManager ? CapabilityManager->GetAllCapabilities() : TArray<UBaseCapability*>(); \
	} \
	\
	TArray<UBaseCapability*> ClassName::GetActiveCapabilities() const \
	{ \
		return CapabilityManager ? CapabilityManager->GetActiveCapabilities() : TArray<UBaseCapability*>(); \
	} \
	\
	void ClassName::RemoveComponent(UActorComponent* Component) \
	{ \
		if (CapabilityManager) \
		{ \
			CapabilityManager->RemoveActorComponent(Component); \
		} \
	} \
	\
	void ClassName::UpdateCapabilityStates() \
	{ \
		if (CapabilityManager) \
		{ \
			CapabilityManager->UpdateCapabilityStates(); \
		} \
	}

// Common ECS component and properties
#define DECLARE_ECS_COMPONENT() \
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "ECS", meta = (AllowPrivateAccess = "true")) \
	UCapabilityManagerComponent* CapabilityManager; \
	\
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS") \
	bool bManualCapabilityTicking = true;

// Common ECS initialization in constructor
#define INITIALIZE_ECS_COMPONENT(ComponentName) \
	CapabilityManager = CreateDefaultSubobject<UCapabilityManagerComponent>(ComponentName); \
	if (CapabilityManager) \
	{ \
		CapabilityManager->SetComponentTickEnabled(false); \
	}

// Common ECS BeginPlay implementation
#define ECS_BEGIN_PLAY() \
	if (CapabilityManager) \
	{ \
		CapabilityManager->UpdateCapabilityStates(); \
	}

// Common ECS Tick implementation
#define ECS_TICK(DeltaTime) \
	if (bManualCapabilityTicking && CapabilityManager) \
	{ \
		CapabilityManager->ManualTick(DeltaTime); \
	}