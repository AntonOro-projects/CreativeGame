// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"

#include "BaseComponent.generated.h"

/**
 * Base component class that serves as a pure data container.
 * Components should NEVER tick and only store data that capabilities can access and modify.
 */
UCLASS(BlueprintType, Blueprintable, meta = (BlueprintSpawnableComponent))
class CREATIVEGAME_API UBaseComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	UBaseComponent();

protected:
	// Called when the game starts
	virtual void BeginPlay() override;

public:
	// Optional: Add common data that all components might need
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Component Data")
	bool bIsEnabled = true;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Component Data", meta = (MultiLine = true))
	FString Description;
};
