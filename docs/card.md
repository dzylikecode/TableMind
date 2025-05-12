![](card.excalidraw.svg)

## model

```python
@dataclass
class CardModel:
  cost: Cost
  title: str
  symbol: Symbol
  description: str
  tag: Tag
  location: Location
  time: Time
```