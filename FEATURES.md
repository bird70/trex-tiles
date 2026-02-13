# Enhanced Viewer Features

The viewers now include advanced cartographic features for better visualization of river line data.

## New Features

### 1. Zoom-Based Stream Order Filtering

Rivers are filtered by stream order based on zoom level, showing only relevant detail:

- **Zoom 0-6**: Only major rivers (order 6+)
- **Zoom 7-8**: Rivers order 5+
- **Zoom 9-10**: Rivers order 4+
- **Zoom 11-12**: Rivers order 3+
- **Zoom 13-14**: Rivers order 2+
- **Zoom 15+**: All rivers (order 1+)

This prevents visual clutter at low zoom levels and reveals smaller streams as you zoom in.

### 2. Color Classification by Relative Values

Lines are colored by the `relativevalues95thpercentile` attribute using a 5-class scheme:

| Class | Range | Color | Hex |
|-------|-------|-------|-----|
| Very High | ≥ 0.8 | Red | #d73027 |
| High | 0.6 - 0.8 | Orange | #fc8d59 |
| Medium | 0.4 - 0.6 | Yellow | #fee090 |
| Low | 0.2 - 0.4 | Light Blue | #91bfdb |
| Very Low | < 0.2 | Dark Blue | #4575b4 |

Colors use a diverging color scheme (RdYlBu) that's colorblind-friendly.

### 3. Variable Line Width by Stream Order

Line width increases with stream order and zoom level:

- **Order 1**: 0.5-2px (smallest streams)
- **Order 2**: 0.8-3px
- **Order 3**: 1-4px
- **Order 4**: 1.2-5px
- **Order 5**: 1.5-6px
- **Order 6**: 2-7px
- **Order 7**: 2.5-8px
- **Order 8**: 3-10px (largest rivers)

Width scales exponentially with zoom for better visibility.

### 4. Interactive Features

- **Click on any river** to see:
  - Stream order
  - River ID (rchid)
  - Relative value with classification
  
- **Hover effects**: Cursor changes to pointer over rivers

- **Legend**: Shows color classification and notes about line width

### 5. Visual Enhancements

- 85% opacity for better basemap visibility
- Smooth line rendering
- Responsive design for mobile/desktop
- Navigation controls (zoom, rotate)

## Technical Implementation

### MapLibre GL JS Expressions

The viewer uses advanced MapLibre expressions:

```javascript
// Zoom-based filtering
filter: [
  'any',
  ['all', ['<=', ['zoom'], 6], ['>=', ['get', 'streamorder'], 6]],
  // ... more conditions
]

// Color by attribute
'line-color': [
  'case',
  ['>=', ['get', 'relativevalues95thpercentile'], 0.8], '#d73027',
  // ... more classes
]

// Width by stream order and zoom
'line-width': [
  'interpolate',
  ['linear'],
  ['get', 'streamorder'],
  1, ['interpolate', ['exponential', 1.5], ['zoom'], 10, 0.5, 14, 1],
  // ... more orders
]
```

## Performance Considerations

1. **Zoom-based filtering** reduces features rendered at low zoom levels
2. **SQL queries** in t-rex config limit attributes by zoom (fewer attributes = smaller tiles)
3. **Vector tiles** are cached by CloudFront in production
4. **Simplification** reduces geometry complexity at lower zooms

## Customization

To adjust the visualization:

### Change Color Breaks

Edit the `line-color` expression in the viewer:

```javascript
'line-color': [
  'case',
  ['>=', ['get', 'relativevalues95thpercentile'], 0.9], '#d73027', // Adjust threshold
  // ...
]
```

### Modify Zoom Thresholds

Edit the filter expression:

```javascript
filter: [
  'any',
  ['all', ['<=', ['zoom'], 8], ['>=', ['get', 'streamorder'], 7]], // Show order 7+ until zoom 8
  // ...
]
```

### Adjust Line Widths

Edit the `line-width` expression:

```javascript
'line-width': [
  'interpolate',
  ['linear'],
  ['get', 'streamorder'],
  1, ['interpolate', ['exponential', 1.5], ['zoom'], 10, 1, 14, 2], // Wider lines
  // ...
]
```

## Files Updated

- `app/static/index.html` - Local viewer (served by t-rex)
- `aws/viewer.html` - Production viewer (for S3)
- `viewer.html` - Standalone viewer (same features)

All three viewers now have identical functionality with these enhanced features.

## Testing

View the enhanced viewer at:
- http://localhost:6767/index.html (local)
- Or open `viewer.html` in your browser

Try:
1. Zooming in/out to see stream order filtering
2. Clicking on rivers to see their attributes
3. Comparing colors across different rivers
4. Observing line width changes with zoom
