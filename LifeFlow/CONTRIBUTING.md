# Contributing to LifeFlow

Thank you for your interest in contributing to LifeFlow! This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Focus on the code, not the person
- Provide constructive feedback
- Help others succeed

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/LifeFlow.git`
3. Create a feature branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Push to your fork and create a pull request

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/add-blood-request-notifications
# or
git checkout -b bugfix/fix-eligibility-check
# or
git checkout -b docs/update-api-documentation
```

### 2. Make Changes

- Write clean, readable code
- Follow the project's coding standards
- Add tests for new functionality
- Update documentation as needed

### 3. Commit Messages

Use clear, descriptive commit messages:

```
feat: add blood request notifications via SMS
fix: resolve null pointer exception in donor eligibility check
docs: update API endpoint documentation
test: add unit tests for inventory reservation
refactor: simplify blood type matching logic
```

Format: `<type>: <description>`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Test additions/updates
- `refactor`: Code refactoring
- `chore`: Maintenance tasks

### 4. Push and Create Pull Request

```bash
git push origin feature/add-blood-request-notifications
# Then create PR on GitHub with description
```

## Code Standards

### Java Code Style

```java
// ✓ Good: Clear variable names, proper spacing
public class DonorService {
    private final DonorRepository donorRepository;
    
    public Donor getDonorById(Long donorId) {
        return donorRepository.findById(donorId)
            .orElseThrow(() -> new DonorNotFoundException("Donor not found"));
    }
}

// ✗ Bad: Unclear names, poor formatting
public class DS {
    private DR dr;
    
    public D gDB(Long id) {
        Optional<D> d = dr.findById(id);
        if(d.isEmpty()) throw new Exception("Not found");
        return d.get();
    }
}
```

### Best Practices

```java
// 1. Use dependency injection
@Service
public class DonorService {
    private final DonorRepository donorRepository;
    private final EventPublisher eventPublisher;
    
    // Constructor injection (preferred)
    public DonorService(DonorRepository repository, EventPublisher publisher) {
        this.donorRepository = repository;
        this.eventPublisher = publisher;
    }
}

// 2. Use Optional instead of null checks
public Donor findDonor(Long id) {
    return donorRepository.findById(id)
        .orElseThrow(() -> new DonorNotFoundException("Donor not found"));
}

// 3. Use exceptions for error handling
public void validateDonor(Donor donor) {
    if (donor.getBloodType() == null) {
        throw new InvalidDonorException("Blood type required");
    }
}

// 4. Add logging
private static final Logger logger = LoggerFactory.getLogger(DonorService.class);

public void processDonation(Donation donation) {
    logger.info("Processing donation: {}", donation.getId());
    try {
        // Process donation
        logger.debug("Donation processed successfully");
    } catch (Exception e) {
        logger.error("Error processing donation", e);
        throw e;
    }
}

// 5. Write tests
@SpringBootTest
class DonorServiceTest {
    @Mock
    private DonorRepository donorRepository;
    
    @InjectMocks
    private DonorService donorService;
    
    @Test
    void testGetDonorById_Success() {
        Donor donor = new Donor();
        when(donorRepository.findById(1L)).thenReturn(Optional.of(donor));
        
        Donor result = donorService.getDonorById(1L);
        
        assertNotNull(result);
        verify(donorRepository).findById(1L);
    }
}
```

## Testing Requirements

### Unit Tests (Required for all features)

```bash
# Run unit tests
mvn test

# Run specific test
mvn test -Dtest=DonorServiceTest

# Run with coverage
mvn clean test jacoco:report
# Coverage report: target/site/jacoco/index.html
```

### Integration Tests

```bash
# Run integration tests
mvn verify

# These test service interactions with database, message broker, etc.
```

### Test Coverage

- Minimum coverage: 70%
- New code: 80% coverage required
- Critical services: 90% coverage required

## Documentation Requirements

### JavaDoc Comments

```java
/**
 * Checks if a donor is eligible to donate blood.
 *
 * Eligibility criteria:
 * - Blood type must be verified
 * - Weight >= 50kg
 * - Hemoglobin level >= 12.5 g/dL
 * - No recent travel to endemic areas
 *
 * @param donor the donor to check
 * @return true if donor is eligible, false otherwise
 * @throws InvalidDonorException if donor is invalid
 * @see Donor
 * @since 1.0
 */
public boolean isEligible(Donor donor) {
    // Implementation
}
```

### README Updates

Update relevant README files when:
- Adding new API endpoints
- Changing service responsibilities
- Adding new dependencies
- Modifying configuration

## Pull Request Guidelines

### Before Submitting PR

- [ ] Code follows project style guide
- [ ] All tests pass locally
- [ ] New tests added for new functionality
- [ ] Documentation updated
- [ ] Commit messages are clear and descriptive
- [ ] No hardcoded credentials or secrets
- [ ] No sensitive data in code/comments

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Closes #123

## Testing Done
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] Manual testing performed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code review ready
- [ ] All CI checks passing
- [ ] Documentation updated
```

### Review Process

1. **Automated Checks**:
   - Tests must pass
   - Code coverage maintained
   - No lint errors

2. **Code Review** (2 approvals minimum):
   - Logic correctness
   - Code quality
   - Security considerations
   - Documentation completeness

3. **Merge**:
   - Use "Squash and merge" for clean history
   - Delete branch after merge

## Issue Reporting

### Bug Report Template

```markdown
## Description
Clear description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: macOS/Linux/Windows
- Java Version: 17
- Docker Version: 4.20

## Logs/Error Messages
Include relevant log snippets
```

### Feature Request Template

```markdown
## Description
Clear description of the feature

## Motivation
Why this feature is needed

## Proposed Solution
How it could be implemented

## Alternatives
Other approaches considered

## Examples
Mock UI or data examples
```

## Development Tips

### Local Testing

```bash
# Test specific service
docker-compose up donor-service

# View logs
docker-compose logs -f donor-service

# Run tests
mvn test -f services/donor-management-service/pom.xml

# Debug with IDE
# Set breakpoint → Right-click service container → Debug
```

### Common Tasks

```bash
# Add a new feature
git checkout -b feature/new-feature
# Make changes
mvn test
git commit -m "feat: add new feature"
git push

# Fix a bug
git checkout -b bugfix/fix-issue
# Make changes
mvn test
git commit -m "fix: resolve issue #123"
git push

# Update documentation
git checkout -b docs/update-docs
git commit -m "docs: update API documentation"
git push
```

## Performance Considerations

When contributing, consider:

```java
// ✓ Good: Use batch operations
List<Donor> donors = donorRepository.findAll(pageRequest);

// ✗ Bad: N+1 query problem
for (Hospital hospital : hospitals) {
    List<Donor> donors = donorRepository.findByHospital(hospital.getId());
}

// ✓ Good: Use caching
@Cacheable("donors")
public Donor getDonor(Long id) { ... }

// ✗ Bad: Repeated database calls
public List<Donor> getActiveDonors() {
    return donorRepository.findAll().stream()
        .filter(d -> d.isActive())
        .collect(toList());  // Better: use database filter
}

// ✓ Good: Use pagination for large results
public Page<Donor> searchDonors(String query, Pageable pageable) {
    return donorRepository.search(query, pageable);
}

// ✗ Bad: Loading all results
public List<Donor> searchDonors(String query) {
    return donorRepository.findAll().stream()
        .filter(d -> d.getName().contains(query))
        .collect(toList());
}
```

## Security Guidelines

```java
// ✓ Good: Validate and sanitize input
public Donor createDonor(DonorRequest request) {
    if (!isValidEmail(request.getEmail())) {
        throw new InvalidInputException("Invalid email");
    }
    // Use parameterized queries
    return donorRepository.save(mapToDonor(request));
}

// ✗ Bad: Trust user input
String query = "SELECT * FROM donors WHERE email = '" + email + "'";

// ✓ Good: Use encryption for sensitive data
@Convert(converter = EncryptedAttributeConverter.class)
private String phoneNumber;

// ✓ Good: Use @Secured or @PreAuthorize
@PreAuthorize("hasRole('DONOR')")
public Donor getMyProfile() { ... }

// ✗ Bad: No authentication checks
public Donor getDonor(Long id) {
    return donorRepository.findById(id).orElse(null);
}
```

## Need Help?

- Read the documentation in `docs/` folder
- Check existing issues and PRs
- Ask questions in GitHub Discussions
- Join our Slack community

---

**Thank you for contributing! 🙏**
