import Foundation

// MARK: - JobService
final class JobService {

    static let shared = JobService()
    private init() {}

    // MARK: - Public API

    func fetchJobs(filter: JobFilter) async throws -> [Job] {
        try await Task.sleep(nanoseconds: 600_000_000) // simulate network
        let all = Self.mockJobs
        return applyFilter(filter, to: all)
    }

    func searchJobs(query: String) async throws -> [Job] {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard !query.isEmpty else { return Self.mockJobs }
        let q = query.lowercased()
        return Self.mockJobs.filter {
            $0.title.lowercased().contains(q) ||
            $0.company.lowercased().contains(q) ||
            $0.description.lowercased().contains(q) ||
            $0.requirements.joined(separator: " ").lowercased().contains(q)
        }
    }

    func fetchMoreJobs(filter: JobFilter, page: Int) async throws -> [Job] {
        try await Task.sleep(nanoseconds: 700_000_000)
        // Return shuffled subset for pagination simulation
        return Array(Self.mockJobs.shuffled().prefix(10))
    }

    func fetchFeaturedJobs() async throws -> [Job] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return Array(Self.mockJobs.prefix(6))
    }

    // MARK: - Filter Logic

    private func applyFilter(_ filter: JobFilter, to jobs: [Job]) -> [Job] {
        jobs.filter { job in
            // Keywords
            if !filter.keywords.isEmpty {
                let kw = filter.keywords.lowercased()
                let match = job.title.lowercased().contains(kw) ||
                            job.company.lowercased().contains(kw) ||
                            job.description.lowercased().contains(kw)
                if !match { return false }
            }
            // Job type
            if !filter.jobTypes.isEmpty && !filter.jobTypes.contains(job.jobType) {
                return false
            }
            // Experience level
            if !filter.experienceLevels.isEmpty && !filter.experienceLevels.contains(job.experienceLevel) {
                return false
            }
            // Source
            if !filter.sources.isEmpty && !filter.sources.contains(job.source) {
                return false
            }
            // Posted within
            if let days = filter.postedWithinDays {
                let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
                if job.postedDate < cutoff { return false }
            }
            return true
        }
    }

    // MARK: - Mock Data (25 realistic remote jobs)

    static let mockJobs: [Job] = {
        let now = Date()
        func daysAgo(_ d: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -d, to: now) ?? now
        }

        return [
            Job(
                id: "job-001",
                title: "iOS Software Engineer",
                company: "Shopify",
                location: "Remote – Worldwide",
                salary: "$95,000 – $130,000",
                description: """
Shopify is looking for a talented iOS Software Engineer to join our growing mobile team. You'll be building features used by millions of merchants worldwide. We value craftsmanship, curiosity, and impact.

As part of our fully remote team, you'll collaborate closely with designers, backend engineers, and product managers to ship high-quality iOS experiences. You'll have ownership over entire features from design to deployment.
""",
                requirements: [
                    "Bachelor's degree in Computer Science or equivalent",
                    "2+ years of experience with Swift and UIKit/SwiftUI",
                    "Experience with RESTful APIs and JSON",
                    "Familiarity with Agile/Scrum methodology",
                    "Strong understanding of iOS design patterns (MVVM, MVC)",
                    "Experience with Git version control",
                    "Excellent communication skills for remote collaboration"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(1),
                applicationURL: "https://shopify.com/careers",
                source: .linkedin,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-002",
                title: "Data Analyst",
                company: "GitHub",
                location: "Remote – USA",
                salary: "$80,000 – $110,000",
                description: """
GitHub is seeking a Data Analyst to help us understand how developers use our platform. You'll work with massive datasets to uncover insights that shape our product roadmap.

You'll collaborate with data scientists, product managers, and engineering teams to define metrics, build dashboards, and present actionable insights to leadership.
""",
                requirements: [
                    "Bachelor's degree in Statistics, Mathematics, CS, or related field",
                    "Proficiency in SQL and Python (pandas, numpy)",
                    "Experience with data visualization tools (Tableau, Looker, or similar)",
                    "Strong analytical and problem-solving skills",
                    "Experience with A/B testing and statistical analysis",
                    "Excellent written and verbal communication"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(2),
                applicationURL: "https://github.com/careers",
                source: .indeed,
                isSaved: true,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-003",
                title: "UX Designer",
                company: "Automattic",
                location: "Remote – Worldwide",
                salary: "$85,000 – $120,000",
                description: """
Automattic (makers of WordPress.com, Tumblr, and WooCommerce) is hiring a UX Designer. We are a fully distributed company with employees in 90+ countries.

You'll design intuitive experiences for millions of website owners and bloggers. From wireframing to high-fidelity prototypes, you'll own the design process end-to-end and collaborate asynchronously with global teammates.
""",
                requirements: [
                    "Bachelor's degree in Design, HCI, or related field",
                    "2+ years of UX/product design experience",
                    "Proficiency in Figma",
                    "Strong portfolio showcasing user-centered design process",
                    "Experience conducting user research and usability testing",
                    "Comfortable working asynchronously across time zones"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(3),
                applicationURL: "https://automattic.com/work-with-us",
                source: .weworkremotely,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-004",
                title: "Junior Backend Engineer (Python)",
                company: "Buffer",
                location: "Remote – Worldwide",
                salary: "$75,000 – $95,000",
                description: """
Buffer is a transparent, bootstrapped social media company. We're looking for a Junior Backend Engineer to work on our Python-based API infrastructure.

You'll build and maintain APIs, improve system performance, and ensure reliability. We have a strong culture of documentation and async-first collaboration.
""",
                requirements: [
                    "Bachelor's degree in Computer Science or related",
                    "Proficiency in Python",
                    "Experience with Django or Flask",
                    "Understanding of REST API design principles",
                    "Familiarity with PostgreSQL or other relational databases",
                    "Experience with Git and GitHub",
                    "Strong written communication for async work"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(1),
                applicationURL: "https://buffer.com/journey",
                source: .remoteOK,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-005",
                title: "Frontend Engineer (React)",
                company: "GitLab",
                location: "Remote – USA, Europe",
                salary: "$92,000 – $125,000",
                description: """
GitLab is the world's largest all-remote company and the most comprehensive DevSecOps platform. We're hiring a Frontend Engineer to work on our web application used by 30M+ users.

You'll collaborate with Product Design and Backend Engineers to implement new features and improve existing ones. All work is done in the open — our issue tracker is public.
""",
                requirements: [
                    "Bachelor's degree in CS or equivalent experience",
                    "Experience with Vue.js or React",
                    "Strong knowledge of JavaScript/TypeScript",
                    "Understanding of CSS/SCSS and responsive design",
                    "Familiarity with GraphQL",
                    "Experience with Jest or similar testing frameworks",
                    "Ability to work across time zones"
                ],
                jobType: .remote,
                experienceLevel: .midLevel,
                postedDate: daysAgo(4),
                applicationURL: "https://gitlab.com/jobs",
                source: .linkedin,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-006",
                title: "Digital Marketing Manager",
                company: "Stripe",
                location: "Remote – USA",
                salary: "$90,000 – $115,000",
                description: """
Stripe is building the economic infrastructure of the internet. We're looking for a Digital Marketing Manager to drive growth campaigns for our developer-facing products.

You'll plan and execute multi-channel campaigns, measure performance, and optimize continuously. You'll work closely with our content, design, and sales teams.
""",
                requirements: [
                    "Bachelor's degree in Marketing, Business, or related field",
                    "3+ years of digital marketing experience",
                    "Experience with Google Ads, Meta Ads, and LinkedIn Ads",
                    "Proficiency in Google Analytics and marketing attribution",
                    "Strong analytical skills and data-driven mindset",
                    "Experience with HubSpot or Marketo",
                    "Excellent project management skills"
                ],
                jobType: .remote,
                experienceLevel: .midLevel,
                postedDate: daysAgo(2),
                applicationURL: "https://stripe.com/jobs",
                source: .indeed,
                isSaved: false,
                applicationStatus: .applied
            ),
            Job(
                id: "job-007",
                title: "Content Writer & Strategist",
                company: "Coinbase",
                location: "Remote – USA",
                salary: "$65,000 – $85,000",
                description: """
Coinbase is building the cryptoeconomy. We're seeking a Content Writer & Strategist to create educational and marketing content that helps people understand and use crypto.

You'll write blog posts, help center articles, social media content, and email campaigns. You'll collaborate with product, marketing, and design teams.
""",
                requirements: [
                    "Bachelor's degree in English, Communications, Journalism, or related",
                    "2+ years of content writing experience",
                    "Excellent writing, editing, and proofreading skills",
                    "Ability to explain complex topics in simple terms",
                    "SEO knowledge and experience with content management systems",
                    "Interest in fintech, cryptocurrency, or blockchain (preferred)",
                    "Portfolio of published work"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(5),
                applicationURL: "https://coinbase.com/careers",
                source: .glassdoor,
                isSaved: true,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-008",
                title: "Junior Project Manager",
                company: "Zapier",
                location: "Remote – USA, Canada",
                salary: "$70,000 – $90,000",
                description: """
Zapier makes automation accessible to everyone. We're looking for a Junior Project Manager to help coordinate cross-functional initiatives across engineering, design, and marketing.

You'll manage project timelines, run sprint ceremonies, track deliverables, and ensure teams have what they need to succeed. Excellent async communication is essential.
""",
                requirements: [
                    "Bachelor's degree in Business, Communications, or related field",
                    "1-2 years of project management or coordinator experience",
                    "Familiarity with Agile/Scrum methodology",
                    "Experience with project management tools (Jira, Asana, Linear)",
                    "Strong organizational and communication skills",
                    "Ability to manage multiple projects simultaneously",
                    "PMP or Scrum certification is a plus"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(3),
                applicationURL: "https://zapier.com/jobs",
                source: .weworkremotely,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-009",
                title: "Financial Analyst",
                company: "Brex",
                location: "Remote – USA",
                salary: "$85,000 – $105,000",
                description: """
Brex is reinventing business finance. We're hiring a Financial Analyst to support FP&A and provide data-driven insights to help scale our business.

You'll build financial models, track KPIs, prepare management reports, and partner with business units to drive strategic decisions.
""",
                requirements: [
                    "Bachelor's degree in Finance, Accounting, Economics, or related",
                    "2+ years of financial analysis or investment banking experience",
                    "Advanced Excel and financial modeling skills",
                    "Experience with SQL for data analysis",
                    "Knowledge of GAAP accounting principles",
                    "Strong attention to detail and analytical mindset",
                    "CFA Level 1 or CPA is a plus"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(6),
                applicationURL: "https://brex.com/careers",
                source: .linkedin,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-010",
                title: "Senior iOS Engineer",
                company: "Airbnb",
                location: "Remote – USA",
                salary: "$160,000 – $200,000",
                description: """
Airbnb is creating a world where anyone can belong anywhere. Join our iOS team to build features that connect hosts and guests across 220+ countries.

You'll lead technical initiatives, mentor junior engineers, and work on complex systems that scale to hundreds of millions of users. High autonomy, high impact.
""",
                requirements: [
                    "Bachelor's degree in CS or equivalent",
                    "5+ years of iOS development with Swift",
                    "Deep knowledge of UIKit and SwiftUI",
                    "Experience with performance optimization and debugging",
                    "Track record of shipping large-scale iOS features",
                    "Ability to mentor and lead other engineers",
                    "Experience with CI/CD pipelines"
                ],
                jobType: .remote,
                experienceLevel: .senior,
                postedDate: daysAgo(1),
                applicationURL: "https://airbnb.com/careers",
                source: .indeed,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-011",
                title: "Machine Learning Engineer",
                company: "Hugging Face",
                location: "Remote – Worldwide",
                salary: "$120,000 – $160,000",
                description: """
Hugging Face is the AI community building the future. We're looking for an ML Engineer to work on our open-source NLP models and the Transformers library.

You'll implement state-of-the-art ML models, optimize training pipelines, and collaborate with researchers and engineers worldwide.
""",
                requirements: [
                    "Bachelor's degree in CS, Math, or related (Master's preferred)",
                    "Strong Python skills with PyTorch or TensorFlow",
                    "Understanding of NLP fundamentals and transformer architectures",
                    "Experience with distributed training",
                    "Open-source contributions are a strong plus",
                    "Ability to read and implement research papers"
                ],
                jobType: .remote,
                experienceLevel: .midLevel,
                postedDate: daysAgo(2),
                applicationURL: "https://huggingface.co/jobs",
                source: .remoteOK,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-012",
                title: "Customer Success Manager",
                company: "Notion",
                location: "Remote – USA, Canada",
                salary: "$70,000 – $90,000",
                description: """
Notion is building an all-in-one workspace for notes, docs, and collaboration. We're looking for a Customer Success Manager to help our enterprise customers achieve their goals.

You'll onboard new clients, build relationships, track adoption metrics, and identify opportunities for expansion. You'll be the voice of customers internally.
""",
                requirements: [
                    "Bachelor's degree in Business, Communications, or related",
                    "2+ years of customer success or account management experience",
                    "Experience with SaaS products",
                    "Strong relationship-building and communication skills",
                    "Data-driven approach to tracking customer health",
                    "Experience with Salesforce or other CRMs",
                    "Passion for productivity tools and workflow optimization"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(4),
                applicationURL: "https://notion.so/careers",
                source: .linkedin,
                isSaved: false,
                applicationStatus: .interview
            ),
            Job(
                id: "job-013",
                title: "DevOps Engineer",
                company: "HashiCorp",
                location: "Remote – USA",
                salary: "$105,000 – $145,000",
                description: """
HashiCorp is a leader in infrastructure automation. We're hiring a DevOps Engineer to work on our cloud infrastructure that powers Terraform, Vault, and Consul.

You'll manage Kubernetes clusters, build CI/CD pipelines, implement IaC, and help teams ship software faster and more reliably.
""",
                requirements: [
                    "Bachelor's degree in CS or related",
                    "Experience with Kubernetes, Docker, and containerization",
                    "Proficiency with Terraform or similar IaC tools",
                    "Experience with AWS, GCP, or Azure",
                    "Knowledge of CI/CD pipelines (GitHub Actions, Jenkins)",
                    "Strong scripting skills (Python, Bash)",
                    "Understanding of networking and security fundamentals"
                ],
                jobType: .remote,
                experienceLevel: .midLevel,
                postedDate: daysAgo(5),
                applicationURL: "https://hashicorp.com/jobs",
                source: .glassdoor,
                isSaved: true,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-014",
                title: "Product Designer",
                company: "Linear",
                location: "Remote – Worldwide",
                salary: "$110,000 – $150,000",
                description: """
Linear builds software for teams that care about quality. We're hiring a Product Designer to shape the future of our issue-tracking and project management platform.

You'll work on every aspect of the product — from user flows to interaction design to visual polish. We value designers who love both craft and strategy.
""",
                requirements: [
                    "Bachelor's degree in Design or related field (or equivalent portfolio)",
                    "3+ years of product design experience at a software company",
                    "Expert Figma skills",
                    "Strong portfolio with shipped product work",
                    "Ability to think at both system and pixel level",
                    "Interest in developer tools and productivity software",
                    "Experience working directly with engineers"
                ],
                jobType: .remote,
                experienceLevel: .midLevel,
                postedDate: daysAgo(7),
                applicationURL: "https://linear.app/careers",
                source: .weworkremotely,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-015",
                title: "Sales Development Representative",
                company: "HubSpot",
                location: "Remote – USA",
                salary: "$55,000 – $75,000 + Commission",
                description: """
HubSpot helps millions of businesses grow better. We're looking for energetic SDRs to prospect, qualify, and develop new business opportunities for our sales team.

You'll reach out to potential customers via email, phone, and social media, qualify leads, and set up meetings for Account Executives.
""",
                requirements: [
                    "Bachelor's degree in any field",
                    "Strong communication and interpersonal skills",
                    "Self-motivated with a competitive drive",
                    "Coachable with a growth mindset",
                    "Experience with CRM tools (Salesforce, HubSpot) is a plus",
                    "Prior sales or customer-facing experience preferred"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(2),
                applicationURL: "https://hubspot.com/careers",
                source: .indeed,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-016",
                title: "Android Developer",
                company: "Duolingo",
                location: "Remote – USA, UK",
                salary: "$100,000 – $140,000",
                description: """
Duolingo's mission is to develop the best education in the world and make it universally available. We're hiring an Android Developer to help build our app used by 50M+ learners daily.

You'll work on our Android app built with Kotlin and Jetpack Compose, implementing new language learning features and improving app performance.
""",
                requirements: [
                    "Bachelor's degree in CS or related",
                    "2+ years of Android development with Kotlin",
                    "Experience with Jetpack Compose or XML views",
                    "Understanding of Android architecture (MVVM, Clean Architecture)",
                    "Experience with coroutines and Flow",
                    "Familiarity with CI/CD for mobile",
                    "Passion for education and language learning"
                ],
                jobType: .remote,
                experienceLevel: .midLevel,
                postedDate: daysAgo(3),
                applicationURL: "https://duolingo.com/careers",
                source: .linkedin,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-017",
                title: "Technical Writer",
                company: "Cloudflare",
                location: "Remote – USA, Europe",
                salary: "$70,000 – $95,000",
                description: """
Cloudflare is on a mission to help build a better Internet. We're looking for a Technical Writer to produce developer documentation, guides, and API references for our global developer platform.

You'll work closely with engineers and product managers to ensure our documentation is accurate, clear, and helpful for developers worldwide.
""",
                requirements: [
                    "Bachelor's degree in CS, English, Communications, or related",
                    "2+ years of technical writing experience",
                    "Experience documenting APIs and developer tools",
                    "Familiarity with Markdown and static site generators",
                    "Ability to understand and explain complex technical concepts",
                    "Experience with git-based documentation workflows",
                    "Knowledge of web technologies (HTTP, DNS, networking basics)"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(8),
                applicationURL: "https://cloudflare.com/careers",
                source: .glassdoor,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-018",
                title: "Growth Marketing Analyst",
                company: "Figma",
                location: "Remote – USA",
                salary: "$80,000 – $105,000",
                description: """
Figma is growing our design community and we need a Growth Marketing Analyst to help us scale. You'll analyze campaign performance, run experiments, and identify opportunities to accelerate user acquisition and retention.

You'll partner with product, design, and marketing teams to build a data-driven growth engine.
""",
                requirements: [
                    "Bachelor's degree in Marketing, Economics, or quantitative field",
                    "2+ years of growth or performance marketing experience",
                    "Strong SQL skills for data analysis",
                    "Experience with growth experimentation and A/B testing",
                    "Knowledge of attribution modeling and marketing analytics",
                    "Proficiency in Excel/Google Sheets",
                    "Experience with Mixpanel, Amplitude, or similar"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(4),
                applicationURL: "https://figma.com/careers",
                source: .linkedin,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-019",
                title: "Senior Data Scientist",
                company: "Spotify",
                location: "Remote – USA, Sweden",
                salary: "$145,000 – $185,000",
                description: """
Spotify is looking for a Senior Data Scientist to work on our recommendation engine and personalization algorithms. You'll help 600M+ users discover music they love.

You'll develop ML models, design experiments, and work closely with engineering to bring data-driven features to production at scale.
""",
                requirements: [
                    "Bachelor's or Master's degree in CS, Statistics, or related",
                    "5+ years of data science experience",
                    "Expert-level Python and SQL skills",
                    "Experience with recommender systems or NLP",
                    "Strong statistical analysis and experimental design skills",
                    "Experience deploying models to production",
                    "Spark or distributed computing experience preferred"
                ],
                jobType: .remote,
                experienceLevel: .senior,
                postedDate: daysAgo(1),
                applicationURL: "https://spotify.com/jobs",
                source: .indeed,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-020",
                title: "Full Stack Engineer (Node + React)",
                company: "Vercel",
                location: "Remote – Worldwide",
                salary: "$110,000 – $150,000",
                description: """
Vercel is the platform for frontend developers. We're hiring a Full Stack Engineer to build features for our cloud infrastructure platform used by 1M+ developers.

You'll work on our Next.js-powered dashboard, edge network management tools, and internal platform services. Fast-paced, high-autonomy environment.
""",
                requirements: [
                    "Bachelor's degree in CS or equivalent experience",
                    "3+ years of full-stack experience with Node.js and React",
                    "TypeScript proficiency",
                    "Experience with Next.js",
                    "Understanding of cloud platforms (AWS/GCP/Azure)",
                    "Experience with PostgreSQL or other relational databases",
                    "Knowledge of web performance optimization"
                ],
                jobType: .remote,
                experienceLevel: .midLevel,
                postedDate: daysAgo(2),
                applicationURL: "https://vercel.com/careers",
                source: .remoteOK,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-021",
                title: "QA Engineer",
                company: "Atlassian",
                location: "Remote – USA, Australia",
                salary: "$85,000 – $115,000",
                description: """
Atlassian builds team collaboration software including Jira and Confluence. We're hiring a QA Engineer to ensure quality across our cloud products used by 300,000+ customers.

You'll design and execute test plans, build automated test suites, and work with engineering teams to catch bugs before they reach production.
""",
                requirements: [
                    "Bachelor's degree in CS or related field",
                    "2+ years of software testing experience",
                    "Experience with test automation frameworks (Selenium, Playwright, Cypress)",
                    "Proficiency in Python or JavaScript for test scripting",
                    "Understanding of Agile/Scrum development",
                    "Experience with API testing (Postman, REST Assured)",
                    "Knowledge of CI/CD integration for automated tests"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(6),
                applicationURL: "https://atlassian.com/company/careers",
                source: .linkedin,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-022",
                title: "Product Manager – Developer Tools",
                company: "Twilio",
                location: "Remote – USA",
                salary: "$115,000 – $155,000",
                description: """
Twilio powers real-time communications for 300,000+ companies. We're looking for a Product Manager for our developer tools and APIs division.

You'll define product vision, gather requirements from developers worldwide, prioritize the roadmap, and work with engineering and design to ship great products.
""",
                requirements: [
                    "Bachelor's degree in CS, Engineering, Business, or related",
                    "3+ years of product management experience",
                    "Technical background or strong technical aptitude",
                    "Experience managing developer-facing products or APIs",
                    "Excellent written and verbal communication",
                    "Data-driven with experience in product analytics",
                    "MBA is a plus but not required"
                ],
                jobType: .remote,
                experienceLevel: .midLevel,
                postedDate: daysAgo(3),
                applicationURL: "https://twilio.com/company/jobs",
                source: .glassdoor,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-023",
                title: "Cybersecurity Analyst",
                company: "Crowdstrike",
                location: "Remote – USA",
                salary: "$90,000 – $125,000",
                description: """
CrowdStrike is the leader in cybersecurity. We're hiring a Cybersecurity Analyst to protect our clients from advanced threats.

You'll monitor security events, investigate incidents, perform threat hunting, and provide analysis and recommendations to strengthen security postures.
""",
                requirements: [
                    "Bachelor's degree in Cybersecurity, CS, or related field",
                    "2+ years of cybersecurity or IT security experience",
                    "CompTIA Security+ or equivalent certification",
                    "Experience with SIEM tools (Splunk, QRadar)",
                    "Knowledge of network protocols and security frameworks",
                    "Understanding of malware analysis and incident response",
                    "CISSP or CEH is a plus"
                ],
                jobType: .remote,
                experienceLevel: .entryLevel,
                postedDate: daysAgo(7),
                applicationURL: "https://crowdstrike.com/careers",
                source: .indeed,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-024",
                title: "Operations Manager",
                company: "Shopify",
                location: "Remote – Canada, USA",
                salary: "$85,000 – $110,000",
                description: """
Shopify is seeking an Operations Manager to help scale our merchant support operations. You'll optimize workflows, lead a distributed team, and implement process improvements.

You'll work cross-functionally with finance, HR, and product teams to ensure operational excellence as Shopify continues to grow.
""",
                requirements: [
                    "Bachelor's degree in Business, Operations, or related field",
                    "3+ years of operations management experience",
                    "Experience managing remote or distributed teams",
                    "Strong analytical skills and experience with data-driven decision making",
                    "Proficiency with operational tools and software",
                    "Excellent communication and leadership skills",
                    "Experience in e-commerce or SaaS is preferred"
                ],
                jobType: .remote,
                experienceLevel: .midLevel,
                postedDate: daysAgo(5),
                applicationURL: "https://shopify.com/careers",
                source: .weworkremotely,
                isSaved: false,
                applicationStatus: .notApplied
            ),
            Job(
                id: "job-025",
                title: "Cloud Solutions Architect",
                company: "Amazon Web Services",
                location: "Remote – USA",
                salary: "$155,000 – $210,000",
                description: """
AWS is looking for a Cloud Solutions Architect to help enterprise customers design and build scalable cloud architectures. You'll be a trusted technical advisor guiding complex cloud migrations and modernization projects.

You'll present at conferences, create reference architectures, and contribute to AWS thought leadership.
""",
                requirements: [
                    "Bachelor's degree in CS, Engineering, or related",
                    "7+ years of IT/software experience",
                    "AWS Solutions Architect Professional certification (or equivalent)",
                    "Deep expertise in at least 3 AWS service areas",
                    "Experience designing large-scale distributed systems",
                    "Excellent presentation and communication skills",
                    "Experience with enterprise customers is required"
                ],
                jobType: .remote,
                experienceLevel: .senior,
                postedDate: daysAgo(1),
                applicationURL: "https://amazon.jobs",
                source: .linkedin,
                isSaved: false,
                applicationStatus: .notApplied
            )
        ]
    }()
}
