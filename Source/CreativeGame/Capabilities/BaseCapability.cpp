#include "BaseCapability.h"

UBaseCapability::UBaseCapability()
{
    // Capabilities are ticked manually by owner, not by the engine
    PrimaryComponentTick.bCanEverTick = false;
    PrimaryComponentTick.bStartWithTickEnabled = false;
    bTickInEditor = false;
    
    // Set up auto-activation behavior
    bAutoActivate = bStartActive;
}

void UBaseCapability::BeginPlay()
{
    Super::BeginPlay();
    
    // Ensure we never accidentally start auto-ticking
    SetComponentTickEnabled(false);
    
    // Activation is handled by UActorComponent's system
    // If bAutoActivate is true, the component will automatically activate
}

void UBaseCapability::OnCapabilityDeactivated_Implementation()
{
}

void UBaseCapability::OnCapabilityActivated_Implementation()
{
}

void UBaseCapability::Activate(bool bReset)
{
    Super::Activate(bReset);
    
    // Call Blueprint event for custom activation logic
    OnCapabilityActivated();
}

void UBaseCapability::Deactivate()
{
    Super::Deactivate();
    
    // Call Blueprint event for custom deactivation logic
    OnCapabilityDeactivated();
}

void UBaseCapability::TickCapability_Implementation(float DeltaTime)
{
    // Override in derived classes for custom behavior
    // This is only called when the capability is active
}

bool UBaseCapability::ShouldBeActive_Implementation() const
{
    // Default implementation - override in derived classes
    return true;
}

bool UBaseCapability::ShouldDeactivate_Implementation() const
{
    // Override in Blueprint or C++
    return false;
}

bool UBaseCapability::ShouldActivate_Implementation() const
{
    // Override in Blueprint or C++
    return true;
}