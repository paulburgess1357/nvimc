"""Abstract base component for entity-component system."""

from abc import ABC, abstractmethod
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .entity import Entity


class Component(ABC):
    """Abstract base class for all components.

    Components are attached to entities and provide specific functionality.
    Test: gd on Entity should jump to entity.py
    """

    def __init__(self) -> None:
        self._owner: "Entity | None" = None
        self._enabled: bool = True

    @property
    def owner(self) -> "Entity | None":
        """Get the entity that owns this component."""
        return self._owner

    @owner.setter
    def owner(self, entity: "Entity | None") -> None:
        """Set the owner entity."""
        self._owner = entity

    @property
    def enabled(self) -> bool:
        """Check if component is enabled."""
        return self._enabled

    @enabled.setter
    def enabled(self, value: bool) -> None:
        """Enable or disable the component."""
        self._enabled = value

    @abstractmethod
    def update(self, delta_time: float) -> None:
        """Update the component. Must be implemented by subclasses.

        Args:
            delta_time: Time elapsed since last update in seconds.
        """
        pass

    @abstractmethod
    def render(self) -> None:
        """Render the component. Must be implemented by subclasses."""
        pass

    def on_attach(self) -> None:
        """Called when component is attached to an entity."""
        pass

    def on_detach(self) -> None:
        """Called when component is detached from an entity."""
        pass
