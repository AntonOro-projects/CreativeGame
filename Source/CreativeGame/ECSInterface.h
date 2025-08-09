// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/Interface.h"
#include "Capabilities/BaseCapability.h"

#include "ECSInterface.generated.h"

class UCapabilityManagerComponent;

// This class does not need to be modified.
UINTERFACE(MinimalAPI, BlueprintType)
class UECSInterface : public UInterface
{
	GENERATED_BODY()
};

/**
 * Interface for ECS functionality.
 * Any Actor that implements this interface can have capability management.
 * This allows for flexible ECS implementation across different Actor types.
 */
class CREATIVEGAME_API IECSInterface
{
	GENERATED_BODY()

public:
	// Capability management interface
	UFUNCTION(BlueprintCallable, BlueprintImplementableEvent, Category = "Capabilities")
	UBaseCapability* AddCapability(TSubclassOf<UBaseCapability> CapabilityClass);

	UFUNCTION(BlueprintCallable, BlueprintImplementableEvent, Category = "Capabilities")
	void AddCapabilityInstance(UBaseCapability* Capability);

	UFUNCTION(BlueprintCallable, BlueprintImplementableEvent, Category = "Capabilities")
	void RemoveCapability(UBaseCapability* Capability);

	UFUNCTION(BlueprintCallable, BlueprintImplementableEvent, Category = "Capabilities")
	UBaseCapability* GetCapability(TSubclassOf<UBaseCapability> CapabilityClass) const;

	UFUNCTION(BlueprintCallable, BlueprintImplementableEvent, Category = "Capabilities")
	TArray<UBaseCapability*> GetCapabilities(TSubclassOf<UBaseCapability> CapabilityClass) const;

	UFUNCTION(BlueprintCallable, BlueprintImplementableEvent, Category = "Capabilities")
	TArray<UBaseCapability*> GetAllCapabilities() const;

	UFUNCTION(BlueprintCallable, BlueprintImplementableEvent, Category = "Capabilities")
	TArray<UBaseCapability*> GetActiveCapabilities() const;

	UFUNCTION(BlueprintCallable, BlueprintImplementableEvent, Category = "Capabilities")
	void UpdateCapabilityStates();

	// Get the capability manager - pure virtual, must be implemented
	virtual UCapabilityManagerComponent* GetCapabilityManager() const = 0;
};