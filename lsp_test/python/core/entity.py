"""Entity class for entity-component system."""

from typing import TypeVar, Generic
from .component import Component

T = TypeVar("T", bound=Component)


class Entity:
    """An entity that can hold multiple components.

    Test LSP features:
    - gd on Component should jump to component.py
    - gr on add_component should show all references
    - K on methods should show docstring
    """

    _next_id: int = 0

    def __init__(self, name: str = "Entity") -> None:
        self._id: int = Entity._next_id
        Entity._next_id += 1
        self._name: str = name
        self._components: list[Component] = []
        self._active: bool = True

    @property
    def id(self) -> int:
        """Unique identifier for this entity."""
        return self._id

    @property
    def name(self) -> str:
        """Name of this entity."""
        return self._name

    @name.setter
    def name(self, value: str) -> None:
        self._name = value

    @property
    def active(self) -> bool:
        """Whether this entity is active."""
        return self._active

    @active.setter
    def active(self, value: bool) -> None:
        self._active = value
        for component in self._components:
            component.enabled = value

    def add_component(self, component: Component) -> None:
        """Add a component to this entity.

        Args:
            component: The component to add.
        """
        if component not in self._components:
            component.owner = self
            self._components.append(component)
            component.on_attach()

    def remove_component(self, component: Component) -> bool:
        """Remove a component from this entity.

        Args:
            component: The component to remove.

        Returns:
            True if component was removed, False if not found.
        """
        if component in self._components:
            component.on_detach()
            component.owner = None
            self._components.remove(component)
            return True
        return False

    def get_component(self, component_type: type[T]) -> T | None:
        """Get first component of specified type.

        Args:
            component_type: The type of component to find.

        Returns:
            The component if found, None otherwise.
        """
        for component in self._components:
            if isinstance(component, component_type):
                return component
        return None

    def get_components(self, component_type: type[T]) -> list[T]:
        """Get all components of specified type.

        Args:
            component_type: The type of components to find.

        Returns:
            List of matching components.
        """
        return [c for c in self._components if isinstance(c, component_type)]

    def update(self, delta_time: float) -> None:
        """Update all enabled components."""
        if not self._active:
            return
        for component in self._components:
            if component.enabled:
                component.update(delta_time)

    def render(self) -> None:
        """Render all enabled components."""
        if not self._active:
            return
        for component in self._components:
            if component.enabled:
                component.render()

    def __repr__(self) -> str:
        return f"Entity(id={self._id}, name='{self._name}')"
