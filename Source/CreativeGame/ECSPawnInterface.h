// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/Interface.h"

#include "ECSPawnInterface.generated.h"

class UCapabilityManagerComponent;

// This class does not need to be modified.
UINTERFACE(MinimalAPI, BlueprintType)
class UECSPawnInterface : public UInterface
{
	GENERATED_BODY()
};

/**
 * Interface for ECS-enabled pawns and characters.
 * Both ABaseECSPawn and ABaseECSCharacter implement this interface.
 */
class CREATIVEGAME_API IECSPawnInterface
{
	GENERATED_BODY()

public:
	// Pure virtual function to get the capability manager
	virtual UCapabilityManagerComponent* GetCapabilityManager() const = 0;
};