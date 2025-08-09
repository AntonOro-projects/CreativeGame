// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Components/CapabilityManagerComponent.h"

#include "BaseECSCharacter.generated.h"

/**
 * Base ECS Character class that manages components and capabilities using the CapabilityManagerComponent.
 * Access capabilities directly through GetCapabilityManager() instead of wrapper functions.
 * This eliminates delegation boilerplate and provides direct component access.
 */
UCLASS(BlueprintType, Blueprintable)
class CREATIVEGAME_API ABaseECSCharacter : public ACharacter
{
	GENERATED_BODY()

public:
	ABaseECSCharacter();

	virtual void Tick(float DeltaTime) override;

	// Direct access to capability manager - this is all you need!
	UFUNCTION(BlueprintPure, Category = "ECS")
	UCapabilityManagerComponent* GetCapabilityManager() const { return CapabilityManager; }

protected:
	virtual void BeginPlay() override;

	// Called to bind functionality to input
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

	// The core ECS functionality component
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "ECS", meta = (AllowPrivateAccess = "true"))
	UCapabilityManagerComponent* CapabilityManager;

	// Control whether this actor manually ticks capabilities or lets the component handle it
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS")
	bool bManualCapabilityTicking = true;
};