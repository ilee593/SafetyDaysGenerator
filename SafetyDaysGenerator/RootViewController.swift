import UIKit

class RootViewController: UIViewController {
    private let posterView = PosterView()
    private let saveButton = UIButton(type: .system)
    private let infoLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF7/255.0, alpha: 1.0)
        setupViews()
        refresh()
    }

    private func setupViews() {
        // 信息标签(顶部)
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .secondaryLabel
        infoLabel.numberOfLines = 2
        infoLabel.textAlignment = .center
        view.addSubview(infoLabel)

        // 海报视图(中间)
        posterView.backgroundColor = .white
        posterView.layer.cornerRadius = 18
        posterView.layer.shadowColor = UIColor.black.cgColor
        posterView.layer.shadowOpacity = 0.10
        posterView.layer.shadowOffset = CGSize(width: 0, height: 6)
        posterView.layer.shadowRadius = 12
        posterView.layer.masksToBounds = false
        view.addSubview(posterView)

        // 保存按钮
        var config = UIButton.Configuration.filled()
        config.title = "保存到相册"
        config.image = UIImage(systemName: "square.and.arrow.down.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor(red: 1.0, green: 0.42, blue: 0.24, alpha: 1.0)
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        saveButton.configuration = config
        saveButton.addAction(UIAction { [weak self] _ in self?.handleSave() }, for: .touchUpInside)
        view.addSubview(saveButton)

        // 转圈
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        // Auto Layout
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        posterView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            posterView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
            posterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            posterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            posterView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),
            posterView.widthAnchor.constraint(equalTo: posterView.heightAnchor, multiplier: 1080.0 / 1440.0),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 52),

            activityIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
        ])
    }

    private func refresh() {
        let now = DayCounter.today()
        let days = DayCounter.daysBetween(start: AppConfig.startDate, end: now)
        let today = DayCounter.dateString(now)
        let weekday = DayCounter.weekdayCN(now)
        let startWeekday = DayCounter.weekdayCN(AppConfig.startDate)

        posterView.update(days: days, today: today, weekday: weekday, startWeekday: startWeekday)
        infoLabel.text = "起始日 \(AppConfig.startDateString)\n今天 \(today) \(weekday) · 第 \(days) 天"
    }

    private func handleSave() {
        Task { @MainActor in
            activityIndicator.startAnimating()
            saveButton.isEnabled = false
            defer {
                activityIndicator.stopAnimating()
                saveButton.isEnabled = true
            }
            let image = posterView.renderAsImage()
            do {
                try await PhotoSaver.save(image: image)
                let alert = UIAlertController(title: "已保存 ✅",
                                              message: "去微信群发一下吧",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好", style: .default))
                present(alert, animated: true)
            } catch {
                let alert = UIAlertController(title: "保存失败",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好", style: .default))
                present(alert, animated: true)
            }
        }
    }
}
