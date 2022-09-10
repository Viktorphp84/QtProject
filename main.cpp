#include <QApplication>
#include <QQmlApplicationEngine>
#include "c_model.h"
#include "parametercalculation.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QApplication app(argc, argv);

    qmlRegisterType<C_Model>("C_Model", 1, 0, "Model");
    qmlRegisterType<ParameterCalculation>("ParameterCalculation", 1, 0, "ParameterCalculation");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    /*QLocale systemLocale = QLocale::system();
    systemLocale.setNumberOptions(QLocale::IncludeTrailingZeroesAfterDot);
    QLocale::setDefault(systemLocale);*/
    engine.load(url);

    /*QList<QObject*> listChild = engine.rootObjects();
    QObject* child = listChild[0];
    QObject* comboBox = child->findChild<QObject*>("comboBox");*/

    return app.exec();
}
