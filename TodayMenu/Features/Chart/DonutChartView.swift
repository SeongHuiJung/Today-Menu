//
//  DonutChartView.swift
//  TodayMenu
//
//  Created by 정성희 on 10/11/25.
//

import UIKit

final class DonutChartView: UIView {

    private var segmentLayers: [CAShapeLayer] = []
    private var chartData: [String] = []
    private var currentRotation: CGFloat = 0

    private let colors: [UIColor] = [
        .systemBlue,
        .systemGreen,
        .systemOrange,
        .systemPurple
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }

    func configure(with data: [String]) {
        self.chartData = data
        drawChart()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !chartData.isEmpty {
            drawChart()
        }
    }
}

// MARK: - Gesture
extension DonutChartView {
    private func rotateChart(by angle: CGFloat) {
        currentRotation = angle
        drawChart()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let location = gesture.location(in: self)

        // 현재 위치로부터 각도 계산
        let angle = atan2(location.y - center.y, location.x - center.x)

        switch gesture.state {
        case .changed:
            // 이전 각도와의 차이를 계산하여 회전
            let previousLocation = CGPoint(
                x: location.x - translation.x,
                y: location.y - translation.y
            )
            let previousAngle = atan2(previousLocation.y - center.y, previousLocation.x - center.x)
            let deltaAngle = angle - previousAngle

            currentRotation += deltaAngle
            rotateChart(by: currentRotation)

            gesture.setTranslation(.zero, in: self)

        default:
            break
        }
    }
    
    private func drawChart() {
        guard !chartData.isEmpty else { return }

        // 기존 레이어 모두 제거
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        segmentLayers.removeAll()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 20
        let innerRadius = radius * 0.6 // 도넛 형태를 위한 내부 반지름

        let totalSegments = chartData.count
        let anglePerSegment = (2 * CGFloat.pi) / CGFloat(totalSegments)

        for (index, _) in chartData.enumerated() {
            let startAngle = CGFloat(index) * anglePerSegment + currentRotation - CGFloat.pi / 2
            let endAngle = startAngle + anglePerSegment

            // 외부 원호
            let outerPath = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )

            // 내부 원호 (반대 방향)
            outerPath.addArc(
                withCenter: center,
                radius: innerRadius,
                startAngle: endAngle,
                endAngle: startAngle,
                clockwise: false
            )

            outerPath.close()

            // 레이어 생성 및 추가
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = outerPath.cgPath
            shapeLayer.fillColor = colors[index % colors.count].cgColor
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = 2

            layer.addSublayer(shapeLayer)
            segmentLayers.append(shapeLayer)
        }

        // 중앙 원 (도넛 홀)
        let centerCircle = CAShapeLayer()
        let centerPath = UIBezierPath(
            arcCenter: center,
            radius: innerRadius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
        centerCircle.path = centerPath.cgPath
        centerCircle.fillColor = UIColor.systemBackground.cgColor
        layer.addSublayer(centerCircle)
    }
}
