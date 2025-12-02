# Contributing to IPulse Studio

Thank you for your interest in contributing to IPulse Studio! This document provides guidelines for contributing to the project.

## Code of Conduct

We are committed to providing a welcoming and inspiring community for all. Please be respectful and constructive in all interactions.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/surreal_2.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Commit with clear, descriptive messages
7. Push to your fork
8. Open a Pull Request

## Development Setup

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Set up database
npm run db:migrate

# Deploy contracts locally
npm run contracts:deploy

# Start development servers
npm run dev:all
```

## Project Structure

- `/contracts` - Solidity smart contracts
- `/sdk` - TypeScript SDK for developers
- `/frontend` - Next.js web application
- `/backend` - API server
- `/ai-engine` - AI generation service
- `/docs` - Documentation

## Coding Standards

### TypeScript/JavaScript

- Use TypeScript for all new code
- Follow ESLint configuration
- Use Prettier for formatting
- Write meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

### Solidity

- Follow Solidity style guide
- Use latest stable version (0.8.23+)
- Add NatSpec comments
- Write comprehensive tests
- Optimize for gas efficiency
- Use OpenZeppelin contracts where applicable

### Git Commits

Follow conventional commits:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Example:
```
feat: add derivative work tracking to SDK

- Implement DerivativeTracker integration
- Add tests for derivative relationships
- Update documentation
```

## Pull Request Process

1. Update documentation for any new features
2. Add tests for new functionality
3. Ensure all tests pass: `npm test`
4. Update README.md if needed
5. Request review from maintainers
6. Address review feedback promptly

## Testing

```bash
# Run all tests
npm test

# Run contract tests
npm run contracts:test

# Run frontend tests
cd frontend && npm test

# Run SDK tests
cd sdk && npm test
```

## Areas for Contribution

### High Priority

- [ ] Additional AI model integrations
- [ ] Mobile application (React Native)
- [ ] Advanced IP analytics features
- [ ] Multi-chain support
- [ ] Performance optimizations

### Medium Priority

- [ ] Additional licensing templates
- [ ] IP valuation improvements
- [ ] Social features (following creators)
- [ ] Advanced search and filtering
- [ ] Notification system

### Good First Issues

- [ ] Documentation improvements
- [ ] UI/UX enhancements
- [ ] Test coverage improvements
- [ ] Bug fixes
- [ ] Code refactoring

## Community

- **Discord**: Join our community for discussions
- **Twitter**: Follow @IPulseStudio for updates
- **GitHub Issues**: Report bugs and request features

## Questions?

Feel free to:
- Open a GitHub issue for bugs or feature requests
- Join our Discord for general questions
- Tag maintainers in PRs for reviews

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to IPulse Studio!** 🎉
