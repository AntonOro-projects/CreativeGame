// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Components/CapabilityManagerComponent.h"
#include "ECSPawnInterface.h"

#include "BaseECSCharacter.generated.h"

// Forward declarations for ECS types
class ABaseECSPlayerController;
class ABaseECSActor;
class ABaseECSPawn;

/**
 * Base ECS Character class that manages components and capabilities using the CapabilityManagerComponent.
 * Access capabilities directly through GetCapabilityManager() instead of wrapper functions.
 * This eliminates delegation boilerplate and provides direct component access.
 * 
 * Provides type-safe access to other ECS classes to ensure we're always working within the ECS ecosystem.
 */
UCLASS(BlueprintType, Blueprintable)
class CREATIVEGAME_API ABaseECSCharacter : public ACharacter, public IECSPawnInterface
{
	GENERATED_BODY()

public:
	ABaseECSCharacter();

	virtual void Tick(float DeltaTime) override;

	// Override possession to ensure we only get possessed by ECS controllers
	virtual void PossessedBy(AController* NewController) override;

	// IECSPawnInterface implementation
	virtual UCapabilityManagerComponent* GetCapabilityManager() const override { return CapabilityManager; }

	// Type-safe access to ECS PlayerController (guaranteed to work if using ECS Game Mode)
	UFUNCTION(BlueprintPure, Category = "ECS")
	ABaseECSPlayerController* GetECSController() const;

	// Helper function to find nearby ECS Actors
	UFUNCTION(BlueprintCallable, Category = "ECS")
	TArray<ABaseECSActor*> GetNearbyECSActors(float Radius) const;

	// Helper function to find ECS Pawns in range
	UFUNCTION(BlueprintCallable, Category = "ECS")
	TArray<ABaseECSPawn*> GetNearbyECSPawns(float Radius) const;

	// Helper function to find other ECS Characters in range
	UFUNCTION(BlueprintCallable, Category = "ECS")
	TArray<ABaseECSCharacter*> GetNearbyECSCharacters(float Radius) const;

protected:
	virtual void BeginPlay() override;

	// Called to bind functionality to input
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

	// Auto-correct non-ECS controllers by replacing them
	UFUNCTION(BlueprintCallable, Category = "ECS")
	ABaseECSPlayerController* CreateECSControllerReplacement(AController* NonECSController);

	// The core ECS functionality component
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "ECS", meta = (AllowPrivateAccess = "true"))
	UCapabilityManagerComponent* CapabilityManager;

	// Control whether this actor manually ticks capabilities or lets the component handle it
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS")
	bool bManualCapabilityTicking = true;

	// Auto-correct non-ECS controllers when possessed
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS")
	bool bAutoCorrectControllers = true;

	// Class to use when creating replacement ECS controllers
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS")
	TSubclassOf<ABaseECSPlayerController> ECSControllerClass;
};