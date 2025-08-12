# TabTogether - Product Requirements Document

## App Overview and Objectives

**App Name:** TabTogether  
**Platform:** iOS (Swift/SwiftUI)  
**Version:** 1.0  
**Target Release:** TBD  

### Mission Statement
TabTogether revolutionizes bill splitting by providing a history-first, intuitive solution that works for any type of bill - from restaurant receipts to vacation expenses, grocery bills to utility statements. The app eliminates the awkwardness and complexity of dividing shared expenses through intelligent OCR technology and flexible splitting options.

### Core Value Proposition

**Universal Bill Support:** Unlike restaurant-focused competitors, TabTogether handles any bill type  
**History-First Experience:** Launch to bill history with easy camera/gallery access  
**Flexible Splitting Methods:** Supports both item-by-item assignment and equal splitting  
**No Account Friction:** Optional account creation with local functionality  
**Intelligent Tax/Tip Distribution:** Automatic proportional distribution of shared costs  

## Target Audience

### Primary Users

**College Students (18-24):** Splitting dorm utilities, grocery runs, group dinners, textbook costs  
**Young Professionals (22-30):** Sharing vacation expenses, restaurant bills, household costs with roommates  

### Secondary Users

**Friend Groups:** Regular social dining and entertainment expenses  
**Roommates:** Ongoing shared household expenses  
**Travel Groups:** Vacation and trip expense management  

### User Personas
**"Sarah the Student":** Junior in college who frequently splits pizza orders, grocery trips, and study group expenses with 3 roommates. Values speed and simplicity over advanced features.  
**"Mike the Young Professional":** 26-year-old who shares a 2BR apartment and frequently organizes group dinners. Needs accurate splitting for both simple and complex bills.

## Core Features and Functionality

### 1. History/Past Bills Screen (Launch Screen)
**Priority:** Must-Have (Phase 1)  
**Feature Description:**  
App launches to a history view showing past bills, with easy access to camera and gallery.

**Acceptance Criteria:**
- App opens to history/past bills view within 2 seconds of launch
- Empty state when no bills exist with clear call-to-action
- List view of existing bills with thumbnails and summary info
- Gallery button prominently displayed (bottom-left)
- Camera button prominently displayed (bottom-right)
- Tap existing bill to view full details and breakdown

**Technical Implementation:**
- SwiftUI NavigationStack for main navigation
- Local data storage with UserDefaults/FileManager
- Empty state design with compelling call-to-action
- List with receipt thumbnails and summary data

### 2. Camera Integration and Capture
**Priority:** Must-Have (Phase 1)  
**Feature Description:**  
Full-screen camera interface accessible from history screen for immediate bill capture.

**Acceptance Criteria:**
- Full-screen camera view accessible from history screen
- Camera capture button prominently displayed and responsive
- Support both portrait and landscape capture orientations
- Image quality optimization for OCR processing
- Return to history after successful capture and processing

**Technical Implementation:**
- AVFoundation for camera capture
- Image preprocessing for optimal OCR results
- Local image storage with compression
- Camera permission handling

### 3. Gallery Integration
**Priority:** Must-Have (Phase 1)  
**Feature Description:**  
Access device photo library to select existing receipt photos.

**Acceptance Criteria:**
- Photo library picker accessible from history screen
- Support standard image formats (JPEG, PNG, HEIC)
- Same OCR processing pipeline as camera capture
- Image quality validation before processing

**Technical Implementation:**
- Photos Framework for photo library access
- PhotosPicker for modern photo selection
- Image format handling and conversion
- Privacy permission management

### 4. Optical Character Recognition (OCR)
**Priority:** Must-Have (Phase 1)  
**Feature Description:**  
Instant text recognition and parsing of bill contents using Vision Framework.

**Acceptance Criteria:**
- Text extraction completes within 3 seconds of image capture
- Accurately detects item names, quantities, and prices
- Automatically identifies tax and tip amounts
- Handles multiple receipt formats (restaurant, grocery, retail, utility)
- Users can manually edit any detected text
- Confidence scoring for detected text elements

**Technical Implementation:**
- Apple Vision Framework for on-device OCR
- Custom parsing algorithms for different receipt formats
- Fallback manual entry interface
- Text confidence indicators

### 5. Participant Management
**Priority:** Must-Have (Phase 2)  
**Feature Description:**  
Add and manage people participating in the bill split without requiring account creation.

**Acceptance Criteria:**
- Add participants by name (text input)
- Support 2-20 participants per bill
- Quick access to recently used names
- Clear visual representation of all participants
- Edit or remove participants before finalizing split

**Technical Implementation:**
- Local name storage and suggestions
- Participant state management
- UI components for participant display and selection

### 6. Item Assignment Interface
**Priority:** Must-Have (Phase 2)  
**Feature Description:**  
Intuitive interface for assigning detected items to specific participants using both tap and drag interactions.

**Acceptance Criteria:**
- Tap Method: Tap item → tap participant name to assign
- Drag Method: Drag item to participant name/area
- Visual feedback during assignment (highlighting, animations)
- Support multiple people per item (shared appetizers, etc.)
- Undo/redo functionality for assignments
- Clear visual indication of assigned vs unassigned items
- Smooth 60fps interactions for all gestures

**Technical Implementation:**
- SwiftUI drag and drop gestures
- State management for item assignments
- Animated feedback components
- Touch target optimization for mobile

### 7. Flexible Splitting Methods
**Priority:** Must-Have (Phase 2)  
**Feature Description:**  
Support both item-by-item assignment and equal splitting, with ability to combine methods within a single bill.

**Acceptance Criteria:**
- Item-by-Item Mode: Individual assignment of each line item
- Equal Split Mode: Divide total amount equally among all participants
- Mixed Mode: Combine both methods (some items individual, others shared equally)
- Toggle between modes without losing existing assignments
- Clear mode indicators and instructions

**Technical Implementation:**
- Calculation engine supporting multiple splitting algorithms
- Mode state management
- Real-time calculation updates

### 8. Tax and Tip Management
**Priority:** Must-Have (Phase 2)  
**Feature Description:**  
Intelligent handling of tax and tip amounts with both automatic detection and manual calculation capabilities.

**Acceptance Criteria:**
- Automatically detect existing tax and tip from receipt
- Built-in tip calculator with percentage options (15%, 18%, 20%, custom)
- Proportional distribution of tax and tip based on each person's bill share
- Manual override for tax/tip amounts
- Real-time calculation updates when tip percentage changes

**Technical Implementation:**
- OCR patterns for tax/tip detection
- Proportional calculation algorithms
- Tip calculator UI component

### 9. Results Display and Calculation
**Priority:** Must-Have (Phase 2)  
**Feature Description:**  
Clear summary showing exactly how much each person owes and to whom.

**Acceptance Criteria:**
- Display each participant's name and total amount owed
- Identify who paid the original bill (bill payer owes $0)
- Show breakdown of each person's items, tax, and tip portions
- Clear "Person X owes $Y to [Bill Payer]" format
- Ability to designate different bill payer after calculation
- Total verification (individual amounts sum to bill total)

**Technical Implementation:**
- Calculation validation logic
- Results display components
- Bill payer designation system

### 10. History and Search
**Priority:** Should-Have (Phase 3)  
**Feature Description:**  
Searchable history of all previous bill splits with detailed breakdowns.

**Acceptance Criteria:**
- Chronological list of all processed bills
- Search by date, amount, participant names, or bill type
- Tap any historical bill to view complete details and breakdown
- Display bill image thumbnail with each history entry
- Sort options (date, amount, number of participants)

**Technical Implementation:**
- Core Data for local database
- CloudKit for cloud sync
- Search indexing and algorithms
- Thumbnail generation and storage

### 11. PDF Export
**Priority:** Should-Have (Phase 3)  
**Feature Description:**  
Export detailed bill breakdown as PDF for record-keeping and sharing.

**Acceptance Criteria:**
- Generate PDF with bill image, item breakdown, and participant amounts
- Professional formatting suitable for expense reports
- Include calculation details and timestamp
- Share via email, messaging, or save to device
- Batch export multiple bills

**Technical Implementation:**
- PDFKit for native PDF generation
- Template-based PDF formatting
- Native sharing integration

### 12. Account Management and Sync
**Priority:** Should-Have (Phase 3)  
**Feature Description:**  
Optional account creation with cloud backup and cross-device sync.

**Acceptance Criteria:**
- Local-first functionality (no account required)
- Optional Sign in with Apple integration
- Cloud backup of bill history and settings
- Cross-device synchronization
- Account deletion with data removal

**Technical Implementation:**
- Firebase Authentication
- CloudKit for cloud storage
- Core Data for local data
- Sync conflict resolution

## Technical Stack Recommendations

### Frontend Framework
**SwiftUI + UIKit**
- Native iOS performance and tight system integration
- Access to latest iOS features and frameworks
- Optimal user experience with 60fps animations
- Native camera and Vision Framework integration

### Backend Services
**Firebase Platform**
- Authentication: Sign in with Apple and Google Sign-In
- Database: Firestore for cloud data sync
- Storage: Cloud Storage for bill images
- Analytics: Firebase Analytics for user insights

### Native Frameworks
**Core iOS Frameworks**
- Vision Framework: On-device OCR processing
- AVFoundation: Camera capture and image processing
- Photos Framework: Photo library access
- Core Data/CloudKit: Local and cloud data persistence
- PDFKit: Native PDF generation for exports

### Development Environment
- Xcode 15+: iOS development and testing
- iOS 17.0+: Minimum deployment target
- Instruments: Performance monitoring and debugging
- Firebase Emulators: Local backend testing

## Conceptual Data Model

### Receipt Entity
```swift
struct Receipt: Identifiable, Codable {
  let id: UUID
  let timestamp: Date
  let imageData: Data
  var totalAmount: Double
  var taxAmount: Double
  var tipAmount: Double
  var detectedTip: Double
  var manualTip: Double
  var tipPercentage: Double?
  var items: [Item]
  var participants: [Participant]
  var splitMethod: SplittingMethod
  var isProcessed: Bool
  let ocrConfidence: Double
  var userId: String? // nil for local-only usage
}
```

### Item Entity
```swift
struct Item: Identifiable, Codable {
  let id: UUID
  var name: String
  var price: Double
  var quantity: Int
  var assignedTo: [String] // participant IDs
  var isSharedEqually: Bool
  let ocrConfidence: Double
  var category: String?
}
```

### Participant Entity
```swift
struct Participant: Identifiable, Codable {
  let id: UUID
  var name: String
  var totalOwed: Double
  var assignedItems: [String] // item IDs
  var taxOwed: Double
  var tipOwed: Double
  var isPayer: Bool
}
```

### Calculation Result Entity
```swift
struct CalculationResult: Codable {
  let receiptId: UUID
  let participants: [ParticipantSummary]
  let totalVerification: TotalVerification
  let generatedAt: Date
}

struct ParticipantSummary: Codable {
  let name: String
  let itemsTotal: Double
  let taxOwed: Double
  let tipOwed: Double
  let totalOwed: Double
  let itemBreakdown: [ItemDetail]
}
```

## User Interface Design Principles

### Design Philosophy
**Minimalism with Purpose:** Every screen element serves a clear function in the bill-splitting workflow.  
**History-First Interface:** The app experience begins with immediate access to past bills and easy bill capture.  
**Progressive Disclosure:** Complex features (editing, manual entry) accessible but not prominent in primary flow.

### Navigation Structure
```
Launch → History View
         ├── Gallery (bottom-left)
         ├── Camera (bottom-right)  
         └── Existing Bill Tap → Bill Details
                     ↓
Gallery/Camera → OCR Processing → Participant Entry → Item Assignment → Results → Save → History
```

### Interaction Patterns
**Primary Actions:** Large touch targets (44pt minimum)  
**Drag Feedback:** Visual indicators during item assignment  
**Error States:** Clear messaging with suggested solutions  
**Loading States:** Progress indicators for OCR processing  
**Success States:** Confirmation animations and clear next steps

### Accessibility Considerations
**VoiceOver support** for all interactive elements  
**Dynamic Type support** for text scaling  
**High contrast mode** compatibility  
**Haptic feedback** for important actions

## Security and Privacy Considerations

### Data Protection
**Local Storage Encryption:** All sensitive data encrypted at rest  
**Image Privacy:** Receipt images stored locally with optional cloud backup  
**Minimal Data Collection:** Only necessary information for functionality  
**User Consent:** Clear opt-in for cloud features and data collection

### Authentication Security
**Firebase Security Rules:** Restrict data access to authenticated users only  
**Token Management:** Secure handling of authentication tokens  
**Account Deletion:** Complete data removal upon account deletion

## Development Phases and Milestones

### Phase 1: Foundation (Weeks 1-4)
**Milestone:** Functional camera capture and OCR processing

**Deliverables:**
- Project setup and navigation structure
- History screen with empty state
- Camera integration with AVFoundation
- Gallery integration with Photos Framework
- Vision Framework integration for OCR
- Image preprocessing and text extraction
- Basic item detection and parsing
- Manual editing interface for OCR results

**Acceptance Criteria:**
✅ App launches to history interface  
✅ Can capture receipt images via camera or gallery  
✅ OCR extracts text with 80%+ accuracy on common receipts  
✅ Users can manually edit detected text

### Phase 2: Core Splitting Features (Weeks 5-10)
**Milestone:** Complete bill splitting workflow

**Deliverables:**
- Participant management system
- Item assignment interface (tap and drag methods)
- Basic calculation engine
- Tip calculator integration
- Tax and tip distribution logic
- Results display and verification
- Equal split and mixed mode functionality
- Error handling and edge cases

**Acceptance Criteria:**
✅ Complete workflow from capture to results  
✅ Both tap and drag assignment methods working  
✅ Accurate tax/tip distribution  
✅ Support for equal and mixed splitting modes

### Phase 3: Data Management and Polish (Weeks 11-14)
**Milestone:** History, search, export, and cloud sync

**Deliverables:**
- Core Data implementation for local storage
- Enhanced history interface and search functionality
- Firebase integration setup
- PDF export functionality using PDFKit
- Cloud sync and account management
- Performance optimization and testing
- App Store preparation

**Acceptance Criteria:**
✅ Bill history with search capability  
✅ PDF export functionality working  
✅ Optional account creation and cloud sync  
✅ App Store ready build

## Technical Challenges and Solutions

### 1. OCR Accuracy Across Receipt Types
**Challenge:** Different merchants use varying receipt formats, fonts, and layouts.  
**Solution:**
- Implement multiple OCR preprocessing pipelines for different receipt types
- Use machine learning models trained on diverse receipt datasets
- Provide confidence scoring and manual correction interface
- Build receipt format detection to choose optimal processing pipeline

### 2. Real-Time Drag and Drop Performance
**Challenge:** Smooth 60fps interactions during item assignment with multiple participants.  
**Solution:**
- Use SwiftUI native drag and drop for optimal performance
- Implement efficient state management for assignments
- Optimize view updates with @State and @Binding
- Use native gesture recognizers for touch interactions

### 3. Complex Split Calculations
**Challenge:** Accurate proportional tax/tip distribution with mixed splitting methods.  
**Solution:**
- Build comprehensive calculation engine with unit tests
- Implement validation checks to ensure totals match
- Provide clear breakdown of calculation logic to users
- Handle edge cases like rounding errors and zero-amount items

### 4. Cross-Platform Receipt Format Variations
**Challenge:** Receipts from different countries, languages, and business types.  
**Solution:**
- Start with US English receipts for MVP
- Build modular parsing system for easy localization
- Implement fallback manual entry for unsupported formats
- Collect user feedback to prioritize format support

## Future Expansion Possibilities

### Version 2.0 Features
**Spending Analytics:** Monthly spending patterns and category breakdowns  
**Group Management:** Persistent groups for regular bill splitting  
**Integration APIs:** Apple Pay, Venmo, Zelle for direct payment requests  
**Multi-Currency Support:** International travel and business expenses

### Version 3.0 Features
**iPad Application:** Optimized interface for larger screens  
**Business Features:** Expense reporting and tax categorization  
**Social Features:** Friend networks and payment reminders  
**AI Recommendations:** Smart tip suggestions and spending insights

### Potential Monetization
**Freemium Model:** Basic splitting free, advanced features premium  
**Export Premium:** PDF exports and advanced history features  
**Business Tier:** Team expense management and reporting tools  
**API Licensing:** White-label OCR and splitting technology

## Success Metrics and KPIs

### User Engagement
**Daily Active Users (DAU):** Target 60% of weekly users  
**Session Duration:** Average 3-5 minutes per session  
**Feature Adoption:** 80% use basic splitting, 40% use advanced features

### Product Performance
**OCR Accuracy:** 90%+ text recognition accuracy  
**Processing Speed:** < 3 seconds from capture to results  
**User Satisfaction:** 4.5+ App Store rating

### Business Metrics
**User Retention:** 40% return after 30 days  
**Organic Growth:** 30% of new users from referrals  
**Market Penetration:** Top 10 finance app in target demographic

## Implementation Notes

This PRD is designed for handoff to development teams and provides:
- Clear acceptance criteria for each feature
- Specific technical recommendations with Swift/SwiftUI focus
- Detailed data models ready for implementation
- Development phases optimized for iterative delivery
- Comprehensive edge case consideration

For questions or clarifications on any aspect of this PRD, refer to the original requirement discussions or consult with the product team.

**Document Version:** 2.0 (Swift)  
**Last Updated:** August 12, 2025

