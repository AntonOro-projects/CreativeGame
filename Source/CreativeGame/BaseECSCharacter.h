// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "ECSInterface.h"
#include "ECSMacros.h"

#include "BaseECSCharacter.generated.h"

/**
 * Base ECS Character class that manages components and capabilities using the CapabilityManagerComponent.
 * This class provides ECS-like functionality where capabilities provide behavior
 * and components provide data storage, built on top of Unreal's Character system.
 */
UCLASS(BlueprintType, Blueprintable)
class CREATIVEGAME_API ABaseECSCharacter : public ACharacter, public IECSInterface
{
	GENERATED_BODY()

public:
	ABaseECSCharacter();

	virtual void Tick(float DeltaTime) override;

	// IECSInterface implementation
	virtual UCapabilityManagerComponent* GetCapabilityManager() const override { return CapabilityManager; }

	// ECS capability management functions
	DECLARE_ECS_CAPABILITY_FUNCTIONS()

protected:
	virtual void BeginPlay() override;

	// Called to bind functionality to input
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

	// ECS component and properties
	DECLARE_ECS_COMPONENT()
};